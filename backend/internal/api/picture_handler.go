package api

import (
	"log/slog"
	"net/http"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/service"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetPictures(s *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		pictures, err := s.GetPictures()
		if err != nil {
			slog.Error("Failed to fetch all pictures", "error", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch pictures"})
			return
		}
		c.JSON(http.StatusOK, pictures)
	}
}

func FindByID(s *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")
		id, err := strconv.ParseUint(idStr, 10, 32)
		if err != nil {
			slog.Warn("Invalid ID format in FindByID", "input", idStr, "error", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
			return
		}

		picture, err := s.FindByID(uint(id))
		if err != nil {
			slog.Warn("Picture not found", "id", id, "error", err)
			c.JSON(http.StatusNotFound, gin.H{"error": "Picture not found"})
			return
		}
		c.JSON(http.StatusOK, picture)
	}
}

// FindByHierarchyID replaces FindByAlbumID
func FindByHierarchyID(s *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")
		id, err := strconv.ParseUint(idStr, 10, 32)
		if err != nil {
			slog.Warn("Invalid Hierarchy ID format", "input", idStr, "error", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Hierarchy ID format"})
			return
		}

		pictures, err := s.FindByHierarchyID(uint(id))
		if err != nil {
			slog.Error("Failed to fetch node pictures", "hierarchy_id", id, "error", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch node pictures"})
			return
		}

		c.JSON(http.StatusOK, pictures)
	}
}

func CreatePicture(s *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req model.Picture
		if err := c.ShouldBindJSON(&req); err != nil {
			slog.Warn("Invalid request body for CreatePicture", "error", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
			return
		}
		if err := s.CreatePicture(&req); err != nil {
			slog.Error("Failed to create picture", "fileName", req.FileName, "error", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create picture"})
			return
		}

		slog.Info("Picture created successfully", "id", req.ID, "fileName", req.FileName)
		c.JSON(http.StatusCreated, req)
	}
}
