package model

type Album struct {
	ID       uint   `gorm:"primaryKey;autoIncrement" json:"id"`
	Uuid     string `gorm:"type:char(36);uniqueIndex" json:"uuid"`
	Name     string `json:"name"`
	Location string `json:"location"`

	SubFolders []SubFolder `json:"sub_folders,omitempty"`
}
