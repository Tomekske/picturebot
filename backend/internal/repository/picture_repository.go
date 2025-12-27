package repository

import (
	"picturebot-backend/internal/model"

	"gorm.io/gorm"
)

type PictureRepository struct {
	db *gorm.DB
}

func NewPictureRepository(db *gorm.DB) *PictureRepository {
	return &PictureRepository{db: db}
}

// Create inserts a new picture into the database.
// NOTE: Ensure picture.SubFolderID is set before calling this.
func (repo *PictureRepository) Create(picture *model.Picture) error {
	if err := repo.db.Create(picture).Error; err != nil {
		return err
	}
	return nil
}

// FindAll retrieves every picture in the database.
func (repo *PictureRepository) FindAll() ([]model.Picture, error) {
	var pictures []model.Picture
	if err := repo.db.Find(&pictures).Error; err != nil {
		return nil, err
	}
	return pictures, nil
}

// FindByAlbumID retrieves all pictures for an album by joining with the SubFolders table.
func (repo *PictureRepository) FindByAlbumID(albumID uint) ([]model.Picture, error) {
	var pictures []model.Picture

	// We MUST join SubFolders because Picture doesn't know about AlbumID directly anymore.
	// SQL: SELECT pictures.* FROM pictures JOIN sub_folders ON sub_folders.id = pictures.sub_folder_id WHERE sub_folders.album_id = ?
	err := repo.db.Joins("JOIN sub_folders ON sub_folders.id = pictures.sub_folder_id").
		Where("sub_folders.album_id = ?", albumID).
		Find(&pictures).Error

	if err != nil {
		return nil, err
	}

	return pictures, nil
}

// FindByID retrieves a picture by its ID.
func (repo *PictureRepository) FindByID(id uint) (*model.Picture, error) {
	var picture model.Picture
	if err := repo.db.First(&picture, id).Error; err != nil {
		return nil, err
	}
	return &picture, nil
}
