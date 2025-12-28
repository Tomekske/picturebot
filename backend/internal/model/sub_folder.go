package model

import (
	"path/filepath"
	"strings"
)

type SubFolder struct {
	ID       uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	Name     string `json:"name"`     // e.g. "RAWs", "JPGs"
	Location string `json:"location"` // e.g. "M:\Picturebot-Test\UUID\RAWs"

	// Belongs To Relation (Link to Hierarchy/Album Node)
	HierarchyID uint      `gorm:"not null;index" json:"hierarchy_id"`
	Hierarchy   Hierarchy `json:"-"`

	// Has Many Relation (Link to Child Pictures)
	Pictures []Picture `json:"pictures,omitempty"`
}

// AddPicture helper (updated to match new Picture struct)
func (sf *SubFolder) AddPicture(filename string, index string) Picture {
	ext := filepath.Ext(filename)
	upperExt := strings.ToUpper(ext)
	pType := "UNKNOWN"

	switch upperExt {
	case ".JPG", ".JPEG", ".PNG":
		pType = "DISPLAY"
	case ".ARW", ".CR2", ".DNG", ".NEF":
		pType = "RAW"
	}

	fullPath := filepath.Join(sf.Location, filename)

	return Picture{
		Index:       index,
		FileName:    filename,
		Extension:   ext,
		Type:        pType,
		Location:    fullPath,
		SubFolderID: sf.ID,
	}
}
