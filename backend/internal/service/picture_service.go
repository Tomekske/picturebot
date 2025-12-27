package service

import (
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
	return s.repo.Create(picture)
}

func (s *PictureService) GetPictures() ([]model.Picture, error) {
	return s.repo.FindAll()
}

func (s *PictureService) FindByID(id uint) (*model.Picture, error) {
	return s.repo.FindByID(id)
}

func (s *PictureService) FindByHierarchyID(hierarchyID uint) ([]model.Picture, error) {
	return s.repo.FindByHierarchyID(hierarchyID)
}
