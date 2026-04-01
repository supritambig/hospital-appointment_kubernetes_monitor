#!/bin/bash
# ============================================
# docker_build_push.sh
# Build and push Docker image to Docker Hub
# ============================================

DOCKER_HUB_USERNAME="your_dockerhub_username"
IMAGE_NAME="hospital-appointment"
TAG="latest"
FULL_IMAGE="$DOCKER_HUB_USERNAME/$IMAGE_NAME:$TAG"

echo "================================================"
echo " Building Docker image: $FULL_IMAGE"
echo "================================================"

docker build -t $FULL_IMAGE .

if [ $? -ne 0 ]; then
  echo "Docker build failed. Exiting."
  exit 1
fi

echo ""
echo "Pushing image to Docker Hub..."
docker push $FULL_IMAGE

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Image pushed successfully: $FULL_IMAGE"
else
  echo "❌ Push failed. Make sure you are logged in: docker login"
  exit 1
fi
