package model

type Picture struct {
	ID          uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	HierarchyID uint   `gorm:"not null;index" json:"hierarchy_id"`
	Index       string `json:"index"`     // e.g. "000001"
	FileName    string `json:"file_name"` // e.g. "000001.ARW" (Renamed version)

	Extension string `json:"extension"`         // e.g. ".ARW"
	Type      string `gorm:"index" json:"type"` // e.g. "RAW", "IMAGE"
	Location  string `json:"location"`          // Full path: "M:\...\RAWs\000001.ARW"

	// Foreign Key: Links to SubFolder, NOT Album directly
	SubFolderID uint      `json:"sub_folder_id"`
	SubFolder   SubFolder `json:"-"`
}
