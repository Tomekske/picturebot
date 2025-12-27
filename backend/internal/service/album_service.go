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

type AlbumService struct {
	albumRepo   *repository.AlbumRepository
	pictureRepo *repository.PictureRepository
}

// fileEntry represents a single file on disk
type fileEntry struct {
	Name      string
	Extension string
	FullPath  string
	ModTime   time.Time
}

// pictureGroup represents a "shot" (e.g., matching ARW + JPG)
type pictureGroup struct {
	BaseName string
	Files    []fileEntry
}

func NewAlbumService(repo *repository.AlbumRepository, pictureRepo *repository.PictureRepository) *AlbumService {
	return &AlbumService{
		albumRepo:   repo,
		pictureRepo: pictureRepo,
	}
}

func (s *AlbumService) GetAlbums() ([]model.Album, error) {
	return s.albumRepo.FindAll()
}

func (s *AlbumService) CreateAlbum(name string) error {
	var root = "M:\\Picturebot-Test"

	var folderNames = []string{"RAWs", "JPGs"}
	album := model.Album{Name: name}
	// --- A. Setup Basic Album Data ---
	id, _ := uuid.NewV7()
	album.Uuid = id.String()

	albumRoot := filepath.Join(root, id.String())
	album.Location = albumRoot

	// --- B. Prepare SubFolders (DB Objects) ---
	// We must create these structure BEFORE saving so GORM creates the IDs
	for _, fName := range folderNames {
		subFolder := model.SubFolder{
			Name:     fName,
			Location: filepath.Join(albumRoot, fName),
		}
		album.SubFolders = append(album.SubFolders, subFolder)
	}

	// --- C. Save Album + SubFolders to DB ---
	// GORM will insert Album -> Insert SubFolders automatically
	// CORRECT: Ignores the album (_), captures the error
	if _, err := s.albumRepo.CreateAlbum(&album); err != nil {
		return errors.New("failed to create test album")
	}

	fmt.Printf("Created DB: %s (UUID: %s)\n", album.Name, album.Uuid)

	// --- D. Create Directories on Disk ---
	if err := os.MkdirAll(albumRoot, 0755); err != nil {
		return errors.New("failed to create album directory")
	}
	for _, sub := range album.SubFolders {
		if err := os.MkdirAll(sub.Location, 0755); err != nil {
			return fmt.Errorf("failed to create subfolder %s", sub.Name)
		}
	}

	// --- E. SPECIAL: Run Import for "Miami Beach" ---
	sourcePath := "M:\\Picturebot-Test\\Pictures" // The source you specified
	fmt.Println("Importing pictures")

	if err := s.ProcessAndImportPictures(sourcePath, &album); err != nil {
		fmt.Printf("  -> Import Failed: %v\n", err)
	} else {
		fmt.Println("  -> Import Complete!")
	}

	return nil
}

// ProcessAndImportPictures handles grouping, sorting, renaming, and DB insertion
func (s *AlbumService) ProcessAndImportPictures(sourceDir string, album *model.Album) error {
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

	// 2. Convert to Slice for Sorting
	var sortedGroups []*pictureGroup
	for _, g := range groupMap {
		sortedGroups = append(sortedGroups, g)
	}

	// 3. Sort Groups by Creation Date (Oldest First)
	sort.Slice(sortedGroups, func(i, j int) bool {
		return getGroupTime(sortedGroups[i]).Before(getGroupTime(sortedGroups[j]))
	})

	// 4. Create Helper Map for SubFolder IDs (Name -> ID)
	// We need this to know which ID belongs to "RAWs" and which to "JPGs"
	subFolderIDs := make(map[string]uint)
	for _, sf := range album.SubFolders {
		subFolderIDs[sf.Name] = sf.ID
	}

	// 5. Rename and Save to DB
	for i, group := range sortedGroups {
		// Generate new Index: 000001
		newIndexStr := fmt.Sprintf("%06d", i+1)

		for _, file := range group.Files {
			upperExt := strings.ToUpper(file.Extension)

			// Determine target folder and type
			targetFolderName := "JPGs"
			picType := "PREVIEW"

			if upperExt == ".ARW" || upperExt == ".CR2" {
				targetFolderName = "RAWs"
				picType = "RAW"
			}

			// New Filename: 000001.ARW
			newFileName := newIndexStr + file.Extension

			// Construct Picture Model
			pic := model.Picture{
				Index:       newIndexStr,
				FileName:    newFileName,
				Extension:   file.Extension,
				Type:        picType,
				Location:    filepath.Join(album.Location, targetFolderName, newFileName),
				SubFolderID: subFolderIDs[targetFolderName], // Link to correct SubFolder!
			}

			// Insert into DB
			if err := s.pictureRepo.Create(&pic); err != nil {
				return err
			}

			fmt.Printf("Processed: %s -> %s\n", file.Name, newFileName)

			// TODO: Uncomment this to actually COPY/MOVE the file on disk
			input, _ := os.ReadFile(file.FullPath)
			err = os.WriteFile(pic.Location, input, 0644)

			if err != nil {
				fmt.Println("Unable to copy file")
				return err
			}
		}
	}

	return nil
}

// Helper: Gets the time of the ARW file in a group, or falls back to the first file
func getGroupTime(g *pictureGroup) time.Time {
	for _, f := range g.Files {
		if strings.ToUpper(f.Extension) == ".ARW" {
			return f.ModTime
		}
	}
	if len(g.Files) > 0 {
		return g.Files[0].ModTime
	}
	return time.Now()
}
