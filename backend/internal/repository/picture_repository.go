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
func (r *PictureRepository) Create(picture *model.Picture) error {
    return r.db.Create(picture).Error
}

// FindAll retrieves every picture in the database.
func (r *PictureRepository) FindAll() ([]model.Picture, error) {
	var pictures []model.Picture

    err := r.db.Find(&pictures).Error
	return pictures, err
}

// FindByID retrieves a picture by its ID.
func (r *PictureRepository) FindByID(id uint) (*model.Picture, error) {
	var picture model.Picture
	err := r.db.First(&picture, id).Error
	return &picture, err
}

// FindByAlbumID retrieves all pictures for an album by joining with the SubFolders table.
func (r *PictureRepository) FindByAlbumID(albumID uint) ([]model.Picture, error) {
    var pictures []model.Picture

	err := r.db.Joins("JOIN sub_folders ON sub_folders.id = pictures.sub_folder_id").
		Where("sub_folders.album_id = ?", albumID).
		Find(&pictures).Error

	return pictures, err
}
