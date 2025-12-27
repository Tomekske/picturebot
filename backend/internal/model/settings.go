package model

type Settings struct {
	ID          uint   `gorm:"primaryKey" json:"id"`
	ThemeMode   string `json:"theme_mode"`
	LibraryPath string `json:"library_path"`
}
