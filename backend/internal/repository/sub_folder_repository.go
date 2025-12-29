package repository

import (
	"log/slog"
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
	err := repo.db.Create(subFolder).Error
	if err != nil {
		slog.Error("Database error: Failed to create subfolder", "name", subFolder.Name, "error", err)
	}
	return err
}

func (repo *SubFolderRepository) FindByHierarchyID(hierarchyID uint) ([]model.SubFolder, error) {
	var subFolders []model.SubFolder
	err := repo.db.Where("hierarchy_id = ?", hierarchyID).Find(&subFolders).Error
	if err != nil {
		slog.Error("Database error: Failed to find subfolders for node", "hierarchyID", hierarchyID, "error", err)
	}
	return subFolders, err
}

func (repo *SubFolderRepository) FindByNameAndHierarchyID(name string, hierarchyID uint) (*model.SubFolder, error) {
	var subFolder model.SubFolder
	err := repo.db.Where("name = ? AND hierarchy_id = ?", name, hierarchyID).First(&subFolder).Error
	if err != nil && err != gorm.ErrRecordNotFound {
		slog.Error("Database error: Failed to find specific subfolder by name", "name", name, "hierarchyID", hierarchyID, "error", err)
	}
	return &subFolder, err
}
