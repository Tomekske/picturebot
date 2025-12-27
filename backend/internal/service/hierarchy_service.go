package service

import (
	"errors"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/repository"

	"github.com/google/uuid"
)

type HierarchyService struct {
	repo *repository.HierarchyRepository
}

func NewHierarchyService(repo *repository.HierarchyRepository) *HierarchyService {
	return &HierarchyService{repo: repo}
}

type CreateNodeRequest struct {
	ParentID uint                `json:"parent_id"`
	Name     string              `json:"name"`
	Type     model.HierarchyType `json:"type"`
}

func (s *HierarchyService) CreateNode(req CreateNodeRequest) (*model.Hierarchy, error) {
	// Handle Root ParentID
	var parentID *uint
	if req.ParentID != 0 {
		parentID = &req.ParentID
	}

	// 2. Prevent Duplicate Folders
	if req.Type == model.TypeFolder {
		exists := s.repo.FindDuplicate(parentID, req.Name, req.Type)
		if exists {
			return nil, errors.New("a folder with this name already exists here")
		}
	}

	// 3. Prepare Node
	newNode := &model.Hierarchy{
		ParentID: parentID,
		Name:     req.Name,
		Type:     req.Type,
		Children: []*model.Hierarchy{}, // Init empty slice
	}

	// 4. Generate UUID for Albums
	if req.Type == model.TypeAlbum {
		newNode.UUID = uuid.NewString()
	}

	if err := s.repo.Create(newNode); err != nil {
		return nil, err
	}

	return newNode, nil
}

// GetFullHierarchy transforms the flat database rows into a nested tree structure.
func (s *HierarchyService) GetFullHierarchy() ([]*model.Hierarchy, error) {
	// 1. Get all nodes flat
	allNodes, err := s.repo.FindAll()
	if err != nil {
		return nil, err
	}

	// 2. Create a lookup map
	nodeMap := make(map[uint]*model.Hierarchy)
	for _, node := range allNodes {
		node.Children = []*model.Hierarchy{}

		nodeMap[node.ID] = node
	}

	// 3. Build Tree
	var rootNodes []*model.Hierarchy

	for _, node := range allNodes {
		if node.ParentID == nil {
			rootNodes = append(rootNodes, node)
		} else {
			if parent, found := nodeMap[*node.ParentID]; found {
				parent.Children = append(parent.Children, node)
			} else {
				// Handle orphans by showing them at root
				rootNodes = append(rootNodes, node)
			}
		}
	}

	return rootNodes, nil
}
