package model

type Picture struct {
	ID          uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	HierarchyID uint   `gorm:"not null;index" json:"hierarchy_id"`

	FileName    string `gorm:"not null" json:"file_name"`
	Index       string `json:"index"`
	Extension   string `json:"extension"`
	Type        string `gorm:"index" json:"type"`
	Location    string `json:"location"`

    // Foreign Key: Links to subfolder, NOT Album directly
	SubFolderID uint      `gorm:"not null;index" json:"sub_folder_id"`
	SubFolder   SubFolder `json:"-"`
}
