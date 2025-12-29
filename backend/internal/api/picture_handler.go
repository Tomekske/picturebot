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
			slog.Warn("API: Invalid ID format in FindByID", "input", idStr, "error", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid ID format"})
			return
		}

		picture, err := s.FindByID(uint(id))
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "Picture not found"})
			return
		}
		c.JSON(http.StatusOK, picture)
	}
}

func FindByHierarchyID(s *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")
		id, err := strconv.ParseUint(idStr, 10, 32)
		if err != nil {
			slog.Warn("API: Invalid Hierarchy ID format", "input", idStr, "error", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Hierarchy ID format"})
			return
		}

		pictures, err := s.FindByHierarchyID(uint(id))
		if err != nil {
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
			slog.Warn("API: Invalid request body for CreatePicture", "error", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
			return
		}
		if err := s.CreatePicture(&req); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create picture"})
			return
		}
		
		c.JSON(http.StatusCreated, req)
	}
}
