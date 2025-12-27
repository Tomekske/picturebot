package repository

import (
	"errors"
	"picturebot-backend/internal/model"

	"gorm.io/gorm"
)

type SettingsRepository struct {
	db *gorm.DB
}

func NewSettingsRepository(db *gorm.DB) *SettingsRepository {
	return &SettingsRepository{db: db}
}

// GetSettings retrieves the first settings row. Returns default if none exist.
func (repo *SettingsRepository) GetSettings() (*model.Settings, error) {
	var settings model.Settings

	// Try to find the first record
	if err := repo.db.First(&settings).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			// Return defaults matching Dart's Settings.initial()
			return &model.Settings{
				ThemeMode:   "system",
				LibraryPath: "",
			}, nil
		}
		return nil, err
	}

	return &settings, nil
}

// UpdateSettings updates the settings. It forces ID=1 to ensure we only have one row.
func (repo *SettingsRepository) UpdateSettings(settings *model.Settings) error {
	// Ensure we always update the "first" row
	var count int64
	repo.db.Model(&model.Settings{}).Count(&count)

	if count == 0 {
		// Create new
		return repo.db.Create(settings).Error
	}

	// Update existing (Assuming ID 1 is the singleton)
	// We first fetch the ID of the existing row to be safe
	var existing model.Settings
	repo.db.First(&existing)
	settings.ID = existing.ID

	return repo.db.Save(settings).Error
}
