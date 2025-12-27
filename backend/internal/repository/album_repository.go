package repository

import (
	"picturebot-backend/internal/model"

	"gorm.io/gorm"
)

type AlbumRepository struct {
	db *gorm.DB
}

func NewAlbumRepository(db *gorm.DB) *AlbumRepository {
	return &AlbumRepository{db: db}
}

func (repo *AlbumRepository) FindAll() ([]model.Album, error) {
	var albums []model.Album

	if err := repo.db.Find(&albums).Error; err != nil {
		return nil, err
	}

	return albums, nil
}

func (repo *AlbumRepository) CreateAlbum(album *model.Album) (*model.Album, error) {
	// If 'Pictures' are defined in the struct, GORM inserts them automatically here!
	if err := repo.db.Create(album).Error; err != nil {
		return nil, err
	}

	return album, nil
}
