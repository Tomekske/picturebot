package main

import (
	"fmt"
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
		slog.Error("failed to connect database", "error", err)
		os.Exit(1)
	}

	currentDate := time.Now().Format("2006-01-02")
	logPath := fmt.Sprintf(`C:\Users\joost\Documents\Picturebot-Go\dev-backend_%s.jsonl`, currentDate)

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

	// Auto-migrate schema
	if err := db.AutoMigrate(
		&model.Picture{},
		&model.SubFolder{},
		&model.Hierarchy{},
		&model.Settings{},
	); err != nil {
		slog.Error("failed to migrate", "error", err)
		os.Exit(1)
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
