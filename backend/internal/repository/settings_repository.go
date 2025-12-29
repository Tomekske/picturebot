package repository

import (
	"log/slog"
	"picturebot-backend/internal/model"

	"gorm.io/gorm"
)

type SettingsRepository struct {
	db *gorm.DB
}

func NewSettingsRepository(db *gorm.DB) *SettingsRepository {
	return &SettingsRepository{db: db}
}

func (r *SettingsRepository) GetSettings() (*model.Settings, error) {
	var settings model.Settings
	err := r.db.FirstOrCreate(&settings, model.Settings{ID: 1}).Error
	if err != nil {
		slog.Error("Database error: Failed to initialize or retrieve settings", "error", err)
	}
	return &settings, err
}

func (r *SettingsRepository) UpdateSettings(settings *model.Settings) error {
	settings.ID = 1
	err := r.db.Save(settings).Error
	if err != nil {
		slog.Error("Database error: Failed to update settings row", "error", err)
	}
	return err
}
