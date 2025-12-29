package service

import (
	"log/slog"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/repository"
)

type SettingsService struct {
	repo *repository.SettingsRepository
}

func NewSettingsService(repo *repository.SettingsRepository) *SettingsService {
	return &SettingsService{repo: repo}
}

func (s *SettingsService) GetSettings() (*model.Settings, error) {
	settings, err := s.repo.GetSettings()
	if err != nil {
		slog.Error("Service error: Failed to get settings", "error", err)
	}

	return settings, err
}

func (s *SettingsService) UpdateSettings(settings *model.Settings) error {
	err := s.repo.UpdateSettings(settings)
	if err != nil {
		slog.Error("Service error: Failed to update settings", "error", err)

		return err
	}

	slog.Info("System settings updated", "id", settings.ID)
	
	return nil
}
