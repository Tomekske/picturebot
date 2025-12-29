package repository

import (
	"log/slog"
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
	if err != nil {
		slog.Error("Database error: Failed to create picture record", "fileName", picture.FileName, "error", err)
	}
	return err
}

func (r *PictureRepository) FindAll() ([]model.Picture, error) {
	var pictures []model.Picture
	err := r.db.Find(&pictures).Error
	if err != nil {
		slog.Error("Database error: Failed to fetch all pictures", "error", err)
	}
	return pictures, err
}

func (r *PictureRepository) FindByID(id uint) (*model.Picture, error) {
	var picture model.Picture
	err := r.db.Preload("SubFolder").First(&picture, id).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		slog.Error("Database error: Failed to fetch picture by ID", "id", id, "error", err)
	}
	return &picture, err
}

func (r *PictureRepository) FindByHierarchyID(hierarchyID uint) ([]model.Picture, error) {
	var pictures []model.Picture
	err := r.db.Joins("JOIN sub_folders ON sub_folders.id = pictures.sub_folder_id").
		Where("sub_folders.hierarchy_id = ?", hierarchyID).
		Find(&pictures).Error

	if err != nil {
		slog.Error("Database error: Join query failed for hierarchy ID", "hierarchyID", hierarchyID, "error", err)
	}
	return pictures, err
}
