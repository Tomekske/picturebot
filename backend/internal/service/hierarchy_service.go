package service

import (
	"errors"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type HierarchyService struct {
	repo repository.HierarchyRepository
}

type CreateNodeRequest struct {
	ParentID uint                `json:"parent_id"`
	Name     string              `json:"name"`
	Type     model.HierarchyType `json:"type"`
}

// NewHierarchyService creates a HierarchyService backed by the provided HierarchyRepository.
func NewHierarchyService(hierarchyRepo repository.HierarchyRepository) *HierarchyService {
	return &HierarchyService{
		repo: hierarchyRepo,
	}
}

func (s *HierarchyService) CreateNode(req CreateNodeRequest) (*model.Hierarchy, error) {
	// 1. ParentID Logic: Convert 0 to nil for the database
	var parentID *uint
	if req.ParentID != 0 {
		parentID = &req.ParentID
	}

	// 2. Check for duplicates ONLY for Folders
	// Albums are allowed to have duplicate names (e.g. visiting "Paris" twice on different dates).
	// Folders usually require unique names within the same parent.
	if req.Type == model.TypeFolder {
		_, err := s.repo.FindByParentAndName(parentID, req.Name, req.Type)
		if err == nil {
			// Folder already exists -> Error
			return nil, errors.New("a folder with this name already exists at this location")
		} else if !errors.Is(err, gorm.ErrRecordNotFound) {
			// Actual database error
			return nil, err
		}
	}

	// 3. Generate UUID if it is an Album
	var nodeUUID string
	if req.Type == model.TypeAlbum {
		nodeUUID = uuid.NewString()
	}

	// 4. Create new node
	newNode := &model.Hierarchy{
		ParentID: parentID,
		Name:     req.Name,
		Type:     req.Type,
		UUID:     nodeUUID, // Unique identifier for albums allows duplicate names
	}

	if err := s.repo.Create(newNode); err != nil {
		return nil, err
	}

	return newNode, nil
}

// GetFullHierarchy retrieves all nodes and assembles them into a tree structure
func (s *HierarchyService) GetFullHierarchy() ([]*model.Hierarchy, error) {
	// 1. Fetch all nodes (Flat list)
	allNodes, err := s.repo.FindAll()
	if err != nil {
		return nil, err
	}

	// 2. Map nodes by ID for quick lookup & Initialize Lists
	nodeMap := make(map[uint]*model.Hierarchy)

	for _, node := range allNodes {
		// IMPORTANT: Initialize slices to empty arrays [] to avoid JSON 'null'
		if node.Children == nil {
			node.Children = []*model.Hierarchy{}
		}
		if node.Pictures == nil {
			node.Pictures = []model.Picture{}
		}

		nodeMap[node.ID] = node
	}

	// 3. Assemble the tree
	// Initialize rootNodes to empty slice so API returns [] instead of null if DB is empty
	rootNodes := []*model.Hierarchy{}

	for _, node := range allNodes {
		if node.ParentID == nil {
			// Root node
			rootNodes = append(rootNodes, node)
		} else {
			// Child node: append to parent's children
			// Since we are working with pointers, this updates the node inside nodeMap/rootNodes
			if parent, exists := nodeMap[*node.ParentID]; exists {
				parent.Children = append(parent.Children, node)
			}
		}
	}

	return rootNodes, nil
}
