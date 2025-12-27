package api

import (
	"log"
	"net/http"
	"picturebot-backend/internal/service"

	"github.com/gin-gonic/gin"
)

// Define the expected JSON structure
type CreateAlbumRequest struct {
	Name string `json:"name" binding:"required"`
}

func GetAlbums(service *service.AlbumService) gin.HandlerFunc {
	return func(c *gin.Context) {
		albums, err := service.GetAlbums()
		if err != nil {
			log.Println("failed to get albums:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
			return
		}

		c.IndentedJSON(http.StatusOK, albums)
	}
}

func CreateAlbum(service *service.AlbumService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req CreateAlbumRequest

		// Parse the incoming JSON into the struct
		if err := c.ShouldBindJSON(&req); err != nil {
			// Return 400 if the JSON is invalid or missing "name"
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		err := service.CreateAlbum(req.Name)
		if err != nil {
			log.Println("failed to create album:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create album"})
			return
		}

		c.IndentedJSON(http.StatusCreated, gin.H{
			"message": "Test albums created",
		})
	}
}
