package repository

import (
	"picturebot-backend/internal/model"

	"gorm.io/gorm"
)

type SubFolderRepository struct {
	db *gorm.DB
}

func NewSubFolderRepository(db *gorm.DB) *SubFolderRepository {
	return &SubFolderRepository{db: db}
}

// Create inserts a new subfolder into the database.
func (repo *SubFolderRepository) Create(subFolder *model.SubFolder) error {
	if err := repo.db.Create(subFolder).Error; err != nil {
		return err
	}
	return nil
}

// FindByAlbumID retrieves all subfolders for a specific album.
func (repo *SubFolderRepository) FindByAlbumID(albumID uint) ([]model.SubFolder, error) {
	var subFolders []model.SubFolder

	if err := repo.db.Where("album_id = ?", albumID).Find(&subFolders).Error; err != nil {
		return nil, err
	}

	return subFolders, nil
}

// FindByNameAndAlbumID is useful if you need to look up an ID by name (e.g. "RAWs")
// inside a specific album logic.
func (repo *SubFolderRepository) FindByNameAndAlbumID(name string, albumID uint) (*model.SubFolder, error) {
	var subFolder model.SubFolder

	if err := repo.db.Where("name = ? AND album_id = ?", name, albumID).First(&subFolder).Error; err != nil {
		return nil, err
	}

	return &subFolder, nil
}
