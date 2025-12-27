package service

import (
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
	return s.repo.GetSettings()
}

func (s *SettingsService) UpdateSettings(settings *model.Settings) error {
	return s.repo.UpdateSettings(settings)
}
