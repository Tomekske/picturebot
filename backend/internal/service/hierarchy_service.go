package service

import (
	"errors"
	"fmt"
	"io"
	"log/slog"
	"os"
	"path/filepath"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/repository"
	"sort"
	"strings"
	"time"

	"github.com/google/uuid"
)

type pictureGroup struct {
	BaseName string
	Files    []fileEntry
}

type fileEntry struct {
	Name      string
	Extension string
	FullPath  string
	ModTime   time.Time
}

type HierarchyService struct {
	repo        *repository.HierarchyRepository
	pictureRepo *repository.PictureRepository
}

func NewHierarchyService(repo *repository.HierarchyRepository, pictureRepo *repository.PictureRepository) *HierarchyService {
	return &HierarchyService{
		repo:        repo,
		pictureRepo: pictureRepo,
	}
}

type CreateNodeRequest struct {
	ParentID   uint                `json:"parent_id"`
	Name       string              `json:"name"`
	Type       model.HierarchyType `json:"type"`
	SubFolders []model.SubFolder   `json:"sub_folders"`
	SourcePath string              `json:"source_path"`
}

// CreateNode handles the business logic for creating folders and albums, including disk operations.
func (s *HierarchyService) CreateNode(req CreateNodeRequest) (*model.Hierarchy, error) {
	var parentID *uint
	if req.ParentID != 0 {
		parentID = &req.ParentID
	}

	// Prevent Duplicate Folders
	if req.Type == model.TypeFolder {
		exists, err := s.repo.FindDuplicate(parentID, req.Name, req.Type)
		if err != nil {
			slog.Error("Service error: failed to check for duplicate folders", "name", req.Name, "error", err)
			return nil, err
		}

		if exists {
			slog.Info("Service: Attempted to create duplicate folder", "name", req.Name)
			return nil, errors.New("a folder with this name already exists here")
		}
	}

	newNode := &model.Hierarchy{
		ParentID:   parentID,
		Name:       req.Name,
		Type:       req.Type,
		Children:   []*model.Hierarchy{},
		SubFolders: req.SubFolders,
	}

	// Album Logic: UUID generation and directory creation
	if req.Type == model.TypeAlbum {
		id, err := uuid.NewV7()
		if err != nil {
			slog.Error("Service error: failed to generate UUID", "error", err)
			return nil, fmt.Errorf("failed to generate UUID: %w", err)
		}

		newNode.UUID = id.String()

		if req.SourcePath != "" {
			libraryRoot := "M:\\Picturebot-Test" // Root path for library
			albumRoot := filepath.Join(libraryRoot, newNode.UUID)

			// Prepare standard subfolders
			standardFolders := []string{"RAWs", "JPGs"}
			for _, fName := range standardFolders {
				newNode.SubFolders = append(newNode.SubFolders, model.SubFolder{
					Name:     fName,
					Location: filepath.Join(albumRoot, fName),
				})
			}

			// Create directories on disk
			if err := os.MkdirAll(albumRoot, 0755); err != nil {
				slog.Error("IO error: failed to create album directory", "path", albumRoot, "error", err)
				return nil, fmt.Errorf("failed to create album directory: %w", err)
			}

			for _, sub := range newNode.SubFolders {
				if err := os.MkdirAll(sub.Location, 0755); err != nil {
					slog.Error("IO error: failed to create subfolder", "path", sub.Location, "error", err)
					return nil, fmt.Errorf("failed to create subfolder %s: %w", sub.Name, err)
				}
			}
		}
	}

	if err := s.repo.Create(newNode); err != nil {
		return nil, err
	}

	// Trigger Import process if a SourcePath is provided
	if req.Type == model.TypeAlbum && req.SourcePath != "" {
		slog.Info("Starting import", "source", req.SourcePath, "album", newNode.Name)
		if err := s.processAndImportPictures(req.SourcePath, newNode); err != nil {
			slog.Error("Import failed", "album", newNode.Name, "error", err)
			return newNode, fmt.Errorf("album created but import failed: %w", err)
		}
		slog.Info("Import completed successfully", "album", newNode.Name)
	}

	return newNode, nil
}

// GetFullHierarchy transforms flat database rows into a nested tree structure.
func (s *HierarchyService) GetFullHierarchy() ([]*model.Hierarchy, error) {
	allNodes, err := s.repo.FindAll()
	if err != nil {
		slog.Error("Service: Failed to retrieve full hierarchy", "error", err)
		return nil, err
	}

	nodeMap := make(map[uint]*model.Hierarchy)
	for _, node := range allNodes {
		node.Children = []*model.Hierarchy{}
		nodeMap[node.ID] = node
	}

	var rootNodes []*model.Hierarchy
	for _, node := range allNodes {
		if node.ParentID == nil {
			rootNodes = append(rootNodes, node)
		} else {
			if parent, found := nodeMap[*node.ParentID]; found {
				parent.Children = append(parent.Children, node)
			} else {
				rootNodes = append(rootNodes, node)
			}
		}
	}

	return rootNodes, nil
}

// processAndImportPictures handles file grouping, sorting, renaming, and copying.
func (s *HierarchyService) processAndImportPictures(sourceDir string, hierarchy *model.Hierarchy) error {
	start := time.Now()

	entries, err := os.ReadDir(sourceDir)
	if err != nil {
		slog.Error("IO error: failed to read source directory", "dir", sourceDir, "error", err)
		return fmt.Errorf("failed to read source dir: %w", err)
	}

	groupMap := make(map[string]*pictureGroup)
	for _, e := range entries {
		if e.IsDir() {
			continue
		}

		info, err := e.Info()
		if err != nil {
			slog.Warn("Import warning: failed to get file info", "file", e.Name(), "error", err)
			return fmt.Errorf("failed to get file info for %s: %w", e.Name(), err)
		}

		ext := filepath.Ext(e.Name())
		baseName := strings.TrimSuffix(e.Name(), ext)

		if _, exists := groupMap[baseName]; !exists {
			groupMap[baseName] = &pictureGroup{BaseName: baseName}
		}

		groupMap[baseName].Files = append(groupMap[baseName].Files, fileEntry{
			Name:      e.Name(),
			Extension: ext,
			FullPath:  filepath.Join(sourceDir, e.Name()),
			ModTime:   info.ModTime(),
		})
	}

	var sortedGroups []*pictureGroup
	for _, g := range groupMap {
		sortedGroups = append(sortedGroups, g)
	}
	sort.Slice(sortedGroups, func(i, j int) bool {
		return getGroupTime(sortedGroups[i]).Before(getGroupTime(sortedGroups[j]))
	})

	subFolderIDs := make(map[string]uint)
	for _, sf := range hierarchy.SubFolders {
		subFolderIDs[sf.Name] = sf.ID
	}

	pictureCount := 0

	for i, group := range sortedGroups {
		newIndexStr := fmt.Sprintf("%06d", i+1)

		for _, file := range group.Files {
			upperExt := strings.ToUpper(file.Extension)
			targetFolderName := "JPGs"
			picType := "jpg"

			if upperExt == ".ARW" || upperExt == ".CR2" || upperExt == ".NEF" {
				targetFolderName = "RAWs"
				picType = "raw"
			}

			sfID, ok := subFolderIDs[targetFolderName]
			if !ok {
				slog.Warn("Import warning: target subfolder not found", "folder", targetFolderName, "file", file.Name)
				continue
			}

			var destFolderLocation string
			for _, sf := range hierarchy.SubFolders {
				if sf.ID == sfID {
					destFolderLocation = sf.Location
					break
				}
			}

			newFileName := newIndexStr + file.Extension
			destPath := filepath.Join(destFolderLocation, newFileName)

			pic := model.Picture{
				Index:       newIndexStr,
				FileName:    newFileName,
				Extension:   file.Extension,
				Type:        picType,
				Location:    destPath,
				SubFolderID: sfID,
			}

			if err := s.pictureRepo.Create(&pic); err != nil {
				return err
			}

			if err := copyFile(file.FullPath, destPath); err != nil {
				slog.Error("IO error: file copy failed", "src", file.FullPath, "dst", destPath, "error", err)
				return fmt.Errorf("failed to copy file %s: %w", file.Name, err)
			}

			pictureCount++

			slog.Debug("File imported", "original", file.Name, "imported_as", newFileName)
		}
	}

	duration := time.Since(start)

	slog.Info("Import complete",
		"album", hierarchy.Name,
		"total_pictures", pictureCount,
		"grouped_pictures", pictureCount/2,
		"duration_msg", fmt.Sprintf("Pictures processed in: %.0fs (%s)", duration.Seconds(), duration.Round(time.Second)),
	)

	return nil
}

func getGroupTime(g *pictureGroup) time.Time {
	for _, f := range g.Files {
		upper := strings.ToUpper(f.Extension)
		if upper == ".ARW" || upper == ".CR2" || upper == ".NEF" {
			return f.ModTime
		}
	}
	if len(g.Files) > 0 {
		return g.Files[0].ModTime
	}
	return time.Now()
}

func copyFile(src, dst string) error {
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	dstFile, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	return err
}
