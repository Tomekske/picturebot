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
	return r.db.Create(picture).Error
}

func (r *PictureRepository) FindAll() ([]model.Picture, error) {
	var pictures []model.Picture
	err := r.db.Find(&pictures).Error
	return pictures, err
}

func (r *PictureRepository) FindByID(id uint) (*model.Picture, error) {
	var picture model.Picture
	// Preload SubFolder to know where the file is
	err := r.db.Preload("SubFolder").First(&picture, id).Error
	return &picture, err
}

// FindByHierarchyID retrieves all pictures for a specific Hierarchy Node (Album)
// by joining through the SubFolders table.
func (r *PictureRepository) FindByHierarchyID(hierarchyID uint) ([]model.Picture, error) {
	var pictures []model.Picture

	// SQL: SELECT * FROM pictures
	// JOIN sub_folders ON sub_folders.id = pictures.sub_folder_id
	// WHERE sub_folders.hierarchy_id = ?
	err := r.db.Joins("JOIN sub_folders ON sub_folders.id = pictures.sub_folder_id").
		Where("sub_folders.hierarchy_id = ?", hierarchyID).
		Find(&pictures).Error

	return pictures, err
}