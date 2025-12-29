package service

import (
	"log/slog"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/repository"
)

type PictureService struct {
	repo *repository.PictureRepository
}

func NewPictureService(repo *repository.PictureRepository) *PictureService {
	return &PictureService{repo: repo}
}

func (s *PictureService) CreatePicture(picture *model.Picture) error {
	err := s.repo.Create(picture)
	if err != nil {
		slog.Error("Service error: Failed to create picture", "fileName", picture.FileName, "error", err)
	}
	return err
}

func (s *PictureService) GetPictures() ([]model.Picture, error) {
	pictures, err := s.repo.FindAll()
	if err != nil {
		slog.Error("Service: Failed to fetch all pictures", "error", err)
	}
	return pictures, err
}

func (s *PictureService) FindByID(id uint) (*model.Picture, error) {
	picture, err := s.repo.FindByID(id)
	if err != nil {
		slog.Error("Service error: Failed to find picture by ID", "id", id, "error", err)
	}

	return picture, err
}

func (s *PictureService) FindByHierarchyID(hierarchyID uint) ([]model.Picture, error) {
	pictures, err := s.repo.FindByHierarchyID(hierarchyID)
	if err != nil {
		slog.Error("Service error: Failed to find pictures by hierarchy ID", "hierarchyID", hierarchyID, "error", err)

	}

	return pictures, err
}
