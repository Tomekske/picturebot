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

func (r *PictureRepository) Create(picture *model.Picture) error {
	err := r.db.Create(picture).Error

	return err
}

func (r *PictureRepository) FindAll() ([]model.Picture, error) {
	var pictures []model.Picture
	err := r.db.Find(&pictures).Error

	return pictures, err
}

func (r *PictureRepository) FindByID(id uint) (*model.Picture, error) {
	var picture model.Picture
	err := r.db.Preload("SubFolder").First(&picture, id).Error

	return &picture, err
}

func (r *PictureRepository) FindByHierarchyID(hierarchyID uint) ([]model.Picture, error) {
	var pictures []model.Picture
	err := r.db.Joins("JOIN sub_folders ON sub_folders.id = pictures.sub_folder_id").
		Where("sub_folders.hierarchy_id = ?", hierarchyID).
		Find(&pictures).Error

	return pictures, err
}
