package model

type Settings struct {
	ID          uint   `gorm:"primaryKey" json:"-"`
	ThemeMode   string `gorm:"default:'system'" json:"theme_mode"`
	LibraryPath string `gorm:"default:''" json:"library_path"`
}
