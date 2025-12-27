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
	Location string        `json:"location,omitempty"`
	UUID     string        `gorm:"type:char(36)" json:"uuid,omitempty"`

	Children []*Hierarchy `gorm:"-" json:"children"`
	Pictures []Picture    `gorm:"foreignKey:HierarchyID" json:"pictures"`
}

func NewHierarchy() *Hierarchy {
	return &Hierarchy{
		Children: []*Hierarchy{},
		Pictures: []Picture{},
	}
}
