package service

import (
	"errors"
	"fmt"
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

func (s *HierarchyService) CreateNode(req CreateNodeRequest) (*model.Hierarchy, error) {
	// Handle Root ParentID
	var parentID *uint
	if req.ParentID != 0 {
		parentID = &req.ParentID
	}

	// 2. Prevent Duplicate Folders
	if req.Type == model.TypeFolder {
		exists, err := s.repo.FindDuplicate(parentID, req.Name, req.Type)

		if err != nil {
			return nil, err
		}

		if exists {
			return nil, errors.New("a folder with this name already exists here")
		}
	}

	// 3. Prepare Node
	newNode := &model.Hierarchy{
		ParentID:   parentID,
		Name:       req.Name,
		Type:       req.Type,
		Children:   []*model.Hierarchy{},
		SubFolders: req.SubFolders,
	}

	// 4. Generate UUID for Albums
	// 4. Album Logic (UUID + Disk Creation + Auto-Subfolders)
	if req.Type == model.TypeAlbum {
		newNode.UUID = uuid.NewString()

		// If SourcePath is provided, we assume we want the standard "RAWs/JPGs" structure
		if req.SourcePath != "" {
			libraryRoot := "M:\\Picturebot-Test"
			albumRoot := filepath.Join(libraryRoot, newNode.UUID)

			// A. Create SubFolder structs (GORM will generate IDs on Save)
			standardFolders := []string{"RAWs", "JPGs"}
			for _, fName := range standardFolders {
				newNode.SubFolders = append(newNode.SubFolders, model.SubFolder{
					Name:     fName,
					Location: filepath.Join(albumRoot, fName),
				})
			}

			// B. Create Directories on Disk
			if err := os.MkdirAll(albumRoot, 0755); err != nil {
				return nil, fmt.Errorf("failed to create album directory: %w", err)
			}

			for _, sub := range newNode.SubFolders {
				if err := os.MkdirAll(sub.Location, 0755); err != nil {
					return nil, fmt.Errorf("failed to create subfolder %s: %w", sub.Name, err)
				}
			}
		}
	}

	if err := s.repo.Create(newNode); err != nil {
		return nil, err
	}

	// 6. Trigger Import (After Save)
	// We do this after saving because we need the SubFolder IDs from the DB.
	if req.Type == model.TypeAlbum && req.SourcePath != "" {
		fmt.Printf("Starting import from %s into Album %s...\n", req.SourcePath, newNode.Name)
		if err := s.processAndImportPictures(req.SourcePath, newNode); err != nil {
			fmt.Printf("Error importing pictures: %v\n", err)
			return newNode, fmt.Errorf("album created but import failed: %w", err)
		}
		fmt.Println("Import completed successfully.")
	}

	return newNode, nil
}

// GetFullHierarchy transforms the flat database rows into a nested tree structure.
func (s *HierarchyService) GetFullHierarchy() ([]*model.Hierarchy, error) {
	// 1. Get all nodes flat
	allNodes, err := s.repo.FindAll()
	if err != nil {
		return nil, err
	}

	// 2. Create a lookup map
	nodeMap := make(map[uint]*model.Hierarchy)
	for _, node := range allNodes {
		node.Children = []*model.Hierarchy{}

		nodeMap[node.ID] = node
	}

	// 3. Build Tree
	var rootNodes []*model.Hierarchy

	for _, node := range allNodes {
		if node.ParentID == nil {
			rootNodes = append(rootNodes, node)
		} else {
			if parent, found := nodeMap[*node.ParentID]; found {
				parent.Children = append(parent.Children, node)
			} else {
				// Handle orphans by showing them at root
				rootNodes = append(rootNodes, node)
			}
		}
	}

	return rootNodes, nil
}

func (s *HierarchyService) processAndImportPictures(sourceDir string, hierarchy *model.Hierarchy) error {
	entries, err := os.ReadDir(sourceDir)
	if err != nil {
		return fmt.Errorf("failed to read source dir: %w", err)
	}

	// 1. Group files by Name (e.g. "Miami_Beach_001")
	groupMap := make(map[string]*pictureGroup)

	for _, e := range entries {
		if e.IsDir() {
			continue
		}
		info, _ := e.Info()
		ext := filepath.Ext(e.Name())                 // .ARW
		baseName := strings.TrimSuffix(e.Name(), ext) // Miami_Beach_001

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

	// 2. Sort Groups by Creation Date
	var sortedGroups []*pictureGroup
	for _, g := range groupMap {
		sortedGroups = append(sortedGroups, g)
	}
	sort.Slice(sortedGroups, func(i, j int) bool {
		return getGroupTime(sortedGroups[i]).Before(getGroupTime(sortedGroups[j]))
	})

	// 3. Map SubFolder Names to IDs
	// The 'hierarchy.SubFolders' slice has valid IDs now because we saved it to DB earlier.
	subFolderIDs := make(map[string]uint)
	for _, sf := range hierarchy.SubFolders {
		subFolderIDs[sf.Name] = sf.ID
	}

	// 4. Rename, Copy, and Save
	for i, group := range sortedGroups {
		newIndexStr := fmt.Sprintf("%06d", i+1) // "000001"

		for _, file := range group.Files {
			upperExt := strings.ToUpper(file.Extension)

			targetFolderName := "JPGs"
			picType := "jpg"

			if upperExt == ".ARW" || upperExt == ".CR2" || upperExt == ".NEF" {
				targetFolderName = "RAWs"
				picType = "raw"
			}

			// Ensure we have a valid destination ID
			sfID, ok := subFolderIDs[targetFolderName]
			if !ok {
				fmt.Printf("Warning: Subfolder '%s' not found for file %s. Skipping.\n", targetFolderName, file.Name)
				continue
			}

			// Find destination path
			var destFolderLocation string
			for _, sf := range hierarchy.SubFolders {
				if sf.ID == sfID {
					destFolderLocation = sf.Location
					break
				}
			}

			newFileName := newIndexStr + file.Extension
			destPath := filepath.Join(destFolderLocation, newFileName)

			// Create Picture Model
			pic := model.Picture{
				Index:       newIndexStr,
				FileName:    newFileName,
				Extension:   file.Extension,
				Type:        picType,
				Location:    destPath,
				SubFolderID: sfID,
			}

			// Save Picture to DB
			if err := s.pictureRepo.Create(&pic); err != nil {
				return err
			}

			// Copy File on Disk
			if err := copyFile(file.FullPath, destPath); err != nil {
				return fmt.Errorf("failed to copy file %s: %w", file.Name, err)
			}
			fmt.Printf("Imported: %s -> %s\n", file.Name, newFileName)
		}
	}

	return nil
}

func getGroupTime(g *pictureGroup) time.Time {
	for _, f := range g.Files {
		// Prioritize RAW creation time
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
	input, err := os.ReadFile(src)
	if err != nil {
		return err
	}
	return os.WriteFile(dst, input, 0644)
}
