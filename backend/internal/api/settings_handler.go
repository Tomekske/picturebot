package api

import (
	"net/http"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/service"

	"github.com/gin-gonic/gin"
)

func GetSettings(s *service.SettingsService) gin.HandlerFunc {
	return func(c *gin.Context) {
		settings, err := s.GetSettings()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch settings"})
			return
		}
		c.JSON(http.StatusOK, settings)
	}
}

func UpdateSettings(s *service.SettingsService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req model.Settings

		// Bind JSON to struct
		if err := c.ShouldBindJSON(&req); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
			return
		}

		if err := s.UpdateSettings(&req); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update settings"})
			return
		}

		c.JSON(http.StatusOK, req)
	}
}
