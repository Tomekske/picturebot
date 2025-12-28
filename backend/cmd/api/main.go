package main

import (
	"log"
	"log/slog"
	"os"
	"time"

	"picturebot-backend/internal/api"
	"picturebot-backend/internal/model"
	"picturebot-backend/internal/repository"
	"picturebot-backend/internal/service"

	"github.com/gin-gonic/gin"
	"github.com/glebarez/sqlite"
	"github.com/lmittmann/tint"
	"github.com/mattn/go-colorable"
	"github.com/samber/slog-multi"
	"gopkg.in/natefinch/lumberjack.v2"
	"gorm.io/gorm"
)

func main() {
	db, err := gorm.Open(sqlite.Open("C:\\Users\\joost\\Documents\\Picturebot-Go\\dev.db"), &gorm.Config{})

	if err != nil {
		log.Fatalf("failed to connect database: %v", err)
	}

	const logPath = `C:\Users\joost\Documents\Picturebot-Go\backend.json`

	// Setup Log Rotation
	rotator := &lumberjack.Logger{
		Filename: logPath,
		Compress: true,
	}

	// Setup Tint handler
	consoleHandler := tint.NewHandler(colorable.NewColorable(os.Stderr), &tint.Options{
		Level:      slog.LevelDebug,
		TimeFormat: time.DateTime,
		AddSource:  true,
	})

	// Setup JSON handler
	fileHandler := slog.NewJSONHandler(rotator, &slog.HandlerOptions{
		Level:     slog.LevelDebug,
		AddSource: true,
	})

	// Register handlers
	handler := slogmulti.Fanout(consoleHandler, fileHandler)

	slog.SetDefault(slog.New(handler))

	// Usage
	slog.Info("Application started", "os", "windows", "path", logPath)
	slog.Error("Database connection failed", "error", "timeout")
	slog.Debug("Test")

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
	hierarchyService := service.NewHierarchyService(hierarchyRepo, pictureRepo)
	settingsService := service.NewSettingsService(settingsRepo)

	// Initialize Router
	router := gin.Default()

	// Routes
	router.GET("/pictures", api.GetPictures(pictureService))
	router.GET("/pictures/:id", api.FindByID(pictureService))
	router.GET("/pictures/hierarchy/:id", api.FindByHierarchyID(pictureService))

	router.POST("/hierarchy", api.CreateNode(hierarchyService))
	router.GET("/hierarchy", api.GetHierarchy(hierarchyService))

	router.GET("/settings", api.GetSettings(settingsService))
	router.POST("/settings", api.UpdateSettings(settingsService))

	router.Run("localhost:8080")
}
