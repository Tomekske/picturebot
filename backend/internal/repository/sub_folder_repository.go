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

func (repo *SubFolderRepository) Create(subFolder *model.SubFolder) error {
	return repo.db.Create(subFolder).Error
}

// FindByHierarchyID retrieves all subfolders for a specific Hierarchy node (Album).
func (repo *SubFolderRepository) FindByHierarchyID(hierarchyID uint) ([]model.SubFolder, error) {
	var subFolders []model.SubFolder
	err := repo.db.Where("hierarchy_id = ?", hierarchyID).Find(&subFolders).Error
	return subFolders, err
}

func (repo *SubFolderRepository) FindByNameAndHierarchyID(name string, hierarchyID uint) (*model.SubFolder, error) {
	var subFolder model.SubFolder
	err := repo.db.Where("name = ? AND hierarchy_id = ?", name, hierarchyID).First(&subFolder).Error
	return &subFolder, err
}
