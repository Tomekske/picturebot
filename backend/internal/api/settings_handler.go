package api

import (
	"log"
	"net/http"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/service"

	"github.com/gin-gonic/gin"
)

func GetSettings(service *service.SettingsService) gin.HandlerFunc {
	return func(c *gin.Context) {
		settings, err := service.GetSettings()
		if err != nil {
			log.Println("failed to get settings:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Internal server error"})
			return
		}
		c.JSON(http.StatusOK, settings)
	}
}

func UpdateSettings(service *service.SettingsService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req model.Settings

		// Bind JSON to struct
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}

		if err := service.UpdateSettings(&req); err != nil {
			log.Println("failed to update settings:", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update settings"})
			return
		}

		c.JSON(http.StatusOK, req)
	}
}
