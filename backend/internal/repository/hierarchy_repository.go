package repository

import (
	"picturebot-backend/internal/model"

	"gorm.io/gorm"
)

type HierarchyRepository struct {
	db *gorm.DB
}

func NewHierarchyRepository(db *gorm.DB) *HierarchyRepository {
	return &HierarchyRepository{db: db}
}

// Create inserts a new node.
func (r *HierarchyRepository) Create(node *model.Hierarchy) error {
	return r.db.Create(node).Error
}

// FindAll retrieves every node. Used to build the tree in memory.
func (r *HierarchyRepository) FindAll() ([]*model.Hierarchy, error) {
	var nodes []*model.Hierarchy
	// Retrieve all nodes ordered by Name so the tree looks nice
	err := r.db.
		Preload("SubFolders").
		Preload("SubFolders.Pictures").
		Order("name ASC").
		Find(&nodes).Error
	return nodes, err
}

// FindDuplicate checks if a folder with the same name exists in the same parent folder.
func (r *HierarchyRepository) FindDuplicate(parentID *uint, name string, nodeType model.HierarchyType) (bool, error) {
	var count int64
	query := r.db.Model(&model.Hierarchy{}).Where("name = ? AND type = ?", name, nodeType)

	if parentID == nil {
		query = query.Where("parent_id IS NULL")
	} else {
		query = query.Where("parent_id = ?", parentID)
	}

	if err := query.Count(&count).Error; err != nil {
		return false, err
	}
	return count > 0, nil
}
