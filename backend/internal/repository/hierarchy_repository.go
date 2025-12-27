package repository

import (
	"picturebot-backend/internal/model"

	"gorm.io/gorm"
)

type HierarchyRepository interface {
	// Creates a new node in the database
	Create(node *model.Hierarchy) error

	// Finds a node based on name and parent (for duplicate checks/merging)
	FindByParentAndName(parentID *uint, name string, nodeType model.HierarchyType) (*model.Hierarchy, error)

	// Retrieves all nodes to build the tree structure
	FindAll() ([]*model.Hierarchy, error)
}

type hierarchyRepository struct {
	db *gorm.DB
}

// NewHierarchyRepository creates a HierarchyRepository backed by the provided gorm.DB.
func NewHierarchyRepository(db *gorm.DB) HierarchyRepository {
	return &hierarchyRepository{db: db}
}

// Create implementation
func (r *hierarchyRepository) Create(node *model.Hierarchy) error {
	// GORM automatically handles ParentID (NULL or INT)
	// and fills in CreatedAt/UpdatedAt timestamps.
	return r.db.Create(node).Error
}

// FindByParentAndName implementation (Needed for Merge logic)
func (r *hierarchyRepository) FindByParentAndName(parentID *uint, name string, nodeType model.HierarchyType) (*model.Hierarchy, error) {
	var node model.Hierarchy

	query := r.db.Where("name = ? AND type = ?", name, nodeType)

	if parentID == nil {
		// Search in root (WHERE parent_id IS NULL)
		query = query.Where("parent_id IS NULL")
	} else {
		// Search in specific folder
		query = query.Where("parent_id = ?", parentID)
	}

	err := query.First(&node).Error
	if err != nil {
		return nil, err
	}
	return &node, nil
}

func (r *hierarchyRepository) FindAll() ([]*model.Hierarchy, error) {
	var nodes []*model.Hierarchy
	// Retrieve all nodes. GORM will map columns to struct fields.
	if err := r.db.Find(&nodes).Error; err != nil {
		return nil, err
	}
	return nodes, nil
}