# Stop if any command fails
$ErrorActionPreference = "Stop"

# Store the root location so we can go back if needed
$RootPath = Get-Location

# Navigate into the backend folder (where go.mod lives)
# Adjust "backend" if your folder name is different
Set-Location "$RootPath\backend"

Write-Host "Context switched to: $(Get-Location)" -ForegroundColor Gray
Write-Host "Starting Go Server..." -ForegroundColor Green

# Run the app relative to the backend folder
# Note: path is now cmd/api/main.go, NOT backend/cmd/api/main.go
try {
    # Ensure dependencies are ready (optional, but prevents errors)
    go mod tidy

    # Run the server
    go run cmd/api/main.go
}
catch {
    Write-Error "Failed to run Go server. Error: $_"
}
finally {
    # Always return to root, even if it crashes
    Set-Location $RootPath
}