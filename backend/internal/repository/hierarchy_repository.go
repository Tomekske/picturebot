package repository

import (
	"log/slog"
	"picturebot-backend/internal/model"

	"gorm.io/gorm"
)

type HierarchyRepository struct {
	db *gorm.DB
}

func NewHierarchyRepository(db *gorm.DB) *HierarchyRepository {
	return &HierarchyRepository{db: db}
}

func (r *HierarchyRepository) Create(node *model.Hierarchy) error {
	err := r.db.Create(node).Error
	if err != nil {
		slog.Error("Database error: Failed to create hierarchy node", "name", node.Name, "error", err)
	}
	return err
}

func (r *HierarchyRepository) FindAll() ([]*model.Hierarchy, error) {
	var nodes []*model.Hierarchy
	err := r.db.
		Preload("SubFolders").
		Preload("SubFolders.Pictures").
		Order("name ASC").
		Find(&nodes).Error

	if err != nil {
		slog.Error("Database error: Failed to retrieve full hierarchy", "error", err)
	}
	return nodes, err
}

func (r *HierarchyRepository) FindDuplicate(parentID *uint, name string, nodeType model.HierarchyType) (bool, error) {
	var count int64
	query := r.db.Model(&model.Hierarchy{}).Where("name = ? AND type = ?", name, nodeType)

	if parentID == nil {
		query = query.Where("parent_id IS NULL")
	} else {
		query = query.Where("parent_id = ?", parentID)
	}

	if err := query.Count(&count).Error; err != nil {
		slog.Error("Database error: Failed to check for duplicate hierarchy node", "name", name, "error", err)
		return false, err
	}
	return count > 0, nil
}
