package repository

import (
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
func (r *SettingsRepository) GetSettings() (*model.Settings, error) {
	var settings model.Settings

	// This ensures ID 1 always exists. If not, it inserts the defaults.
	err := r.db.FirstOrCreate(&settings, model.Settings{ID: 1}).Error

	return &settings, err
}

// UpdateSettings updates the settings. It forces ID=1 to ensure we only have one row.
func (r *SettingsRepository) UpdateSettings(settings *model.Settings) error {
	// Force the ID to 1 to ensure we overwrite the singleton record
	settings.ID = 1
	return r.db.Save(settings).Error
}
