package api

import (
	"log/slog"
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
			slog.Warn("Failed to bind JSON for CreateNode", "error", err)
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
				slog.Info("Node creation conflict", "name", req.Name, "parent_id", req.ParentID)
				c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
				return
			}

			slog.Error("Failed to create node", "error", err, "name", req.Name)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create node"})
			return
		}

		slog.Debug("Node created successfully", "id", node.ID, "name", node.Name)
		c.JSON(http.StatusCreated, node)
	}
}

// GetHierarchy returns the whole folder structure nested
func GetHierarchy(s *service.HierarchyService) gin.HandlerFunc {
	return func(c *gin.Context) {
		tree, err := s.GetFullHierarchy()
		if err != nil {
			slog.Error("Failed to build hierarchy tree", "error", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to build hierarchy"})
			return
		}

		slog.Debug("Hierarchy tree retrieved")
		c.JSON(http.StatusOK, tree)
	}
}
