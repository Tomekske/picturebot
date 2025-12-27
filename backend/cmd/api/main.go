package main

import (
	"log"
	"picturebot-backend/internal/api"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/repository"
	"picturebot-backend/internal/service"

	"github.com/gin-gonic/gin"
	"github.com/glebarez/sqlite"
	"gorm.io/gorm"
)

func main() {
	db, err := gorm.Open(sqlite.Open("C:\\Users\\joost\\Documents\\Picturebot-Go\\dev.db"), &gorm.Config{})

	if err != nil {
		log.Fatalf("failed to connect database: %v", err)
	}

	// Auto-migrate schema
	if err := db.AutoMigrate(
		&model.Picture{},
		&model.SubFolder{},
		&model.Hierarchy{},
		&model.Settings{},
	); err != nil {
		log.Fatal("failed to migrate:", err)
	}

    // Initialize Repositories
	pictureRepo := repository.NewPictureRepository(db)
	hierarchyRepo := repository.NewHierarchyRepository(db)
	settingsRepo := repository.NewSettingsRepository(db)

    // Initialize Services
	pictureService := service.NewPictureService(pictureRepo)
	hierarchyService := service.NewHierarchyService(hierarchyRepo)
	settingsService := service.NewSettingsService(settingsRepo)

    // Initialize Router
	router := gin.Default()

    // Routes
	router.GET("/pictures", api.GetPictures(pictureService))
	router.GET("/pictures/:id", api.FindByID(pictureService))
	router.GET("/pictures/album/:id", api.FindByHierarchyID(pictureService))


	router.POST("/hierarchy", api.CreateNode(hierarchyService))
	router.GET("/hierarchy", api.GetHierarchy(hierarchyService))

	router.GET("/settings", api.GetSettings(settingsService))
	router.POST("/settings", api.UpdateSettings(settingsService))

	router.Run("localhost:8080")
}
