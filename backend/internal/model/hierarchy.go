package model

type HierarchyType string

const (
	TypeFolder HierarchyType = "folder"
	TypeAlbum  HierarchyType = "album"
)

type Hierarchy struct {
	ID       uint          `gorm:"primaryKey;autoIncrement" json:"id"`
	ParentID *uint         `gorm:"index" json:"parent_id"`
	Type     HierarchyType `gorm:"size:20;not null" json:"type"`
	Name     string        `gorm:"size:255;not null" json:"name"`
	UUID     string         `gorm:"type:char(36);index" json:"uuid,omitempty"`
	Children []*Hierarchy   `gorm:"-" json:"children"`
	SubFolders []SubFolder `gorm:"foreignKey:HierarchyID" json:"sub_folders,omitempty"`
}
