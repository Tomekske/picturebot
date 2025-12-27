package api

import (
	"net/http"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/service"

	"github.com/gin-gonic/gin"
)

type HierarchyHandler struct {
	service *service.HierarchyService
}

// NewHierarchyHandler creates a HierarchyHandler that uses the provided HierarchyService.
func NewHierarchyHandler(service *service.HierarchyService) *HierarchyHandler {
	return &HierarchyHandler{service: service}
}

// Request struct for binding JSON
type CreateHierarchyRequest struct {
	ParentID uint   `json:"parent_id"` // Removed binding:"required" for root (0)
	Name     string `json:"name" binding:"required"`
	Type     string `json:"type" binding:"required"` // "FOLDER" or "ALBUM"
}

// CreateNode handles the creation of new folders or albums
// CreateNode returns a gin.HandlerFunc that handles POST /api/hierarchy requests to create a hierarchy node.
// It binds the request JSON to CreateHierarchyRequest, invokes the hierarchy service to create the node, and writes the created node as JSON.
// Responds with HTTP 400 for invalid input, HTTP 500 for service errors, and HTTP 201 on success.
func CreateNode(svc *service.HierarchyService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req CreateHierarchyRequest

		// 1. Parse the incoming JSON into the handler struct
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request: " + err.Error()})
			return
		}

		// 2. Map Handler Request to Service Request
		// 'service' here now correctly refers to the package, not the variable
		serviceReq := service.CreateNodeRequest{
			ParentID: req.ParentID,
			Name:     req.Name,
			Type:     model.HierarchyType(req.Type), // Cast string to HierarchyType
		}

		// 3. Call service layer
		node, err := svc.CreateNode(serviceReq)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}

		// 4. Return the created node
		c.JSON(http.StatusCreated, node)
	}
}

// GetHierarchy returns the full tree structure
// GetHierarchy returns a gin.HandlerFunc that responds with the full hierarchy tree as JSON.
// The handler writes HTTP 200 with the hierarchy on success or HTTP 500 with an error message on failure.
func GetHierarchy(svc *service.HierarchyService) gin.HandlerFunc {
	return func(c *gin.Context) {
		tree, err := svc.GetFullHierarchy()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch hierarchy: " + err.Error()})
			return
		}

		c.JSON(http.StatusOK, tree)
	}
}