package api

import (
	"log"
	"net/http"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/service"
	"strconv"

	"github.com/gin-gonic/gin"
)

func GetPictures(service *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		albums, err := service.GetPictures()
		if err != nil {
			log.Println("failed to get albums:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
			return
		}

		c.IndentedJSON(http.StatusOK, albums)
	}
}

func FindByID(service *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		idStr := c.Param("id")
		id, err := strconv.ParseUint(idStr, 10, 64)

		picture, err := service.FindByID(uint(id))
		if err != nil {
			log.Println("failed to get picture:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
			return
		}

		c.IndentedJSON(http.StatusOK, picture)
	}
}

func FindByAlbumID(service *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		albumIDStr := c.Param("id")
		albumID, err := strconv.ParseUint(albumIDStr, 10, 64)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid album ID"})
			return
		}

		pictures, err := service.FindByAlbumID(uint(albumID))
		if err != nil {
			log.Println("failed to get pictures by album ID:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
			return
		}

		c.IndentedJSON(http.StatusOK, pictures)
	}
}

func CreatePicture(service *service.PictureService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var picture model.Picture

		// 1. Parse JSON from the incoming request (body)
		if err := c.ShouldBindJSON(&picture); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		// 2. Pass the parsed picture to the service
		err := service.CreatePicture(&picture)
		if err != nil {
			log.Println("failed to create picture:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create picture"})
			return
		}

		c.IndentedJSON(http.StatusCreated, picture)
	}
}
