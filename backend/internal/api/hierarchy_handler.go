package api

import (
	"net/http"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/service"

	"github.com/gin-gonic/gin"
)

// CreateNode handles creating Folders and Albums
func CreateNode(s *service.HierarchyService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req struct {
			ParentID   uint              `json:"parent_id"`
			Name       string            `json:"name" binding:"required"`
			Type       string            `json:"type" binding:"required"`
			SubFolders []model.SubFolder `json:"sub_folders"`
			SourcePath string            `json:"source_path"`
		}

		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		// Convert to Service Request
		serviceReq := service.CreateNodeRequest{
			ParentID:   req.ParentID,
			Name:       req.Name,
			Type:       model.HierarchyType(req.Type),
			SubFolders: req.SubFolders,
			SourcePath: req.SourcePath,
		}

		node, err := s.CreateNode(serviceReq)
		if err != nil {
			// Check if it's a "duplicate" error to send 409 Conflict
			if err.Error() == "a folder with this name already exists here" {
				c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
				return
			}

			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create node"})
			return
		}

		c.JSON(http.StatusCreated, node)
	}
}

// GetHierarchy returns the whole folder structure nested
func GetHierarchy(s *service.HierarchyService) gin.HandlerFunc {
	return func(c *gin.Context) {
		tree, err := s.GetFullHierarchy()
		if err != nil {

			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to build hierarchy"})
			return
		}
		
		c.JSON(http.StatusOK, tree)
	}
}
