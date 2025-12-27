package service

import (
	"fmt"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/repository"
)

// StorageRepository interface allows us to swap specific file system logic later (or mock it for tests)
// You can define this here or in the repository package.

type PictureService struct {
	repo *repository.PictureRepository
}

func NewPictureService(repo *repository.PictureRepository) *PictureService {
	return &PictureService{
		repo: repo,
	}
}

func (s *PictureService) GetPictures() ([]model.Picture, error) {
	return s.repo.FindAll()
}

func (s *PictureService) CreatePicture(picture *model.Picture) error {
	// Create the picture in the database
	err := s.repo.Create(picture)
	if err != nil {
		return fmt.Errorf("failed to create picture in repository: %w", err)
	}

	return nil
}

func (s *PictureService) FindByID(id uint) (*model.Picture, error) {
	return s.repo.FindByID(id)
}

func (s *PictureService) FindByAlbumID(albumID uint) ([]model.Picture, error) {
	return s.repo.FindByAlbumID(albumID)
}
