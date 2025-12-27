package model

import (
	"path/filepath"
	"strings"
)

type SubFolder struct {
	ID       uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	Name     string `json:"name"`     // e.g. "RAWs", "JPGs"
	Location string `json:"location"` // e.g. "M:\Picturebot-Test\UUID\RAWs"

	// Belongs To Relation (Link to Parent Album)
	AlbumID uint `json:"album_id"`

	// Has Many Relation (Link to Child Pictures)
	Pictures []Picture `json:"pictures,omitempty"`
}

// AddPicture is a helper method to create a Picture entity associated with this folder.
// It automatically calculates the full path, extension, and file type based on the SubFolder's location.
func (sf *SubFolder) AddPicture(filename string, index string) Picture {
	// 1. Get Extension (e.g., ".ARW")
	ext := filepath.Ext(filename)

	// 2. Determine Type (Simple logic)
	// We normalize to uppercase to make checking easier
	upperExt := strings.ToUpper(ext)
	pType := "UNKNOWN"

	switch upperExt {
	case ".JPG", ".JPEG", ".PNG":
		pType = "DISPLAY"
	case ".ARW", ".CR2", ".DNG", ".NEF":
		pType = "RAW"
	}

	// 3. Auto-Construct the Full Path
	// Joins "M:/.../RAWs" + "000001.ARW"
	fullPath := filepath.Join(sf.Location, filename)

	return Picture{
		Index:       index,
		FileName:    filename,
		Extension:   ext,
		Type:        pType,
		Location:    fullPath,
		SubFolderID: sf.ID, // Link this picture to this subfolder
	}
}
