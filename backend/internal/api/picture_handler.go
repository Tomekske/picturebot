package api

import (
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
		// Parse string to uint
		id, err := strconv.ParseUint(idStr, 10, 32)
		if err != nil {
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

func FindByAlbumID(s *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")
		id, err := strconv.ParseUint(idStr, 10, 32)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid Album ID format"})
			return
		}

		pictures, err := s.FindByAlbumID(uint(id))
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch album pictures"})
			return
		}

		c.JSON(http.StatusOK, pictures)
	}
}

func CreatePicture(s *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req model.Picture

		// Bind JSON to struct
		if err := c.ShouldBindJSON(&req); err != nil {
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
