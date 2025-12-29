package api

import (
	"log/slog"
	"net/http"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/service"

	"github.com/gin-gonic/gin"
)

func GetSettings(s *service.SettingsService) gin.HandlerFunc {
	return func(c *gin.Context) {
		settings, err := s.GetSettings()
		if err != nil {
			slog.Error("Failed to fetch system settings", "error", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to fetch settings"})
			return
		}

		slog.Debug("Settings retrieved")
		c.JSON(http.StatusOK, settings)
	}
}

func UpdateSettings(s *service.SettingsService) gin.HandlerFunc {
	return func(c *gin.Context) {
		var req model.Settings

		// Bind JSON to struct
		if err := c.ShouldBindJSON(&req); err != nil {
			slog.Warn("Invalid settings update request", "error", err)
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request body"})
			return
		}

		if err := s.UpdateSettings(&req); err != nil {
			slog.Error("Failed to save settings to database", "error", err)
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to update settings"})
			return
		}

		slog.Info("Settings updated successfully", "settings", req)
		c.JSON(http.StatusOK, req)
	}
}
