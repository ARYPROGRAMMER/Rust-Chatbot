# Docker Build Script for Multi-Architecture Support
# This script builds Docker images for both 32-bit and 64-bit systems

# Exit on error
$ErrorActionPreference = "Stop"

# Configuration
$IMAGE_NAME = "rust-chatbot"
$DOCKER_USERNAME = "YOUR_DOCKERHUB_USERNAME"  # <-- Replace with your DockerHub username
$VERSION = "latest"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Docker Multi-Architecture Build Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "[1/6] Checking Docker..." -ForegroundColor Yellow
docker version | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Docker is not running. Please start Docker Desktop." -ForegroundColor Red
    exit 1
}
Write-Host "Docker is running!" -ForegroundColor Green

# Set up buildx for multi-platform builds
Write-Host ""
Write-Host "[2/6] Setting up Docker Buildx..." -ForegroundColor Yellow
docker buildx create --name multiarch-builder --use 2>$null
docker buildx inspect --bootstrap

# Build for multiple architectures
Write-Host ""
Write-Host "[3/6] Building multi-architecture image..." -ForegroundColor Yellow
Write-Host "This may take a while (10-30 minutes)..." -ForegroundColor Gray

# For local testing (single architecture):
# docker build -t ${IMAGE_NAME}:${VERSION} .

# For multi-architecture (builds and pushes to DockerHub):
docker buildx build `
    --platform linux/amd64,linux/arm64,linux/386,linux/arm/v7 `
    -t "${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}" `
    -t "${DOCKER_USERNAME}/${IMAGE_NAME}:$(Get-Date -Format 'yyyyMMdd')" `
    --push `
    .

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "[4/6] Build completed successfully!" -ForegroundColor Green

# Display image information
Write-Host ""
Write-Host "[5/6] Image Information:" -ForegroundColor Yellow
docker buildx imagetools inspect "${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"

Write-Host ""
Write-Host "[6/6] Done!" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Your image is now available at:" -ForegroundColor Cyan
Write-Host "  docker pull ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
