#!/bin/bash
# Docker Build Script for Multi-Architecture Support
# This script builds Docker images for both 32-bit and 64-bit systems

set -e

# Configuration
IMAGE_NAME="rust-chatbot"
DOCKER_USERNAME="YOUR_DOCKERHUB_USERNAME"  # <-- Replace with your DockerHub username
VERSION="latest"

echo "========================================"
echo "Docker Multi-Architecture Build Script"
echo "========================================"
echo ""

# Check if Docker is running
echo "[1/6] Checking Docker..."
if ! docker version > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker."
    exit 1
fi
echo "Docker is running!"

# Set up buildx for multi-platform builds
echo ""
echo "[2/6] Setting up Docker Buildx..."
docker buildx create --name multiarch-builder --use 2>/dev/null || true
docker buildx inspect --bootstrap

# Build for multiple architectures
echo ""
echo "[3/6] Building multi-architecture image..."
echo "This may take a while (10-30 minutes)..."

# For multi-architecture (builds and pushes to DockerHub):
docker buildx build \
    --platform linux/amd64,linux/arm64,linux/386,linux/arm/v7 \
    -t "${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}" \
    -t "${DOCKER_USERNAME}/${IMAGE_NAME}:$(date +%Y%m%d)" \
    --push \
    .

if [ $? -ne 0 ]; then
    echo "Build failed!"
    exit 1
fi

echo ""
echo "[4/6] Build completed successfully!"

# Display image information
echo ""
echo "[5/6] Image Information:"
docker buildx imagetools inspect "${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"

echo ""
echo "[6/6] Done!"
echo ""
echo "========================================"
echo "Your image is now available at:"
echo "  docker pull ${DOCKER_USERNAME}/${IMAGE_NAME}:${VERSION}"
echo "========================================"
