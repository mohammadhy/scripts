#!/bin/bash

# Variables for image sources and local registry
JAVA_DB_IMAGE="ghcr.io/aquasecurity/trivy-java-db:1"
TRIVY_DB_IMAGE="ghcr.io/aquasecurity/trivy-db:2"
LOCAL_REGISTRY="192.168.42.3:5000"

# Check if ORAS CLI is installed
if ! command -v oras &> /dev/null; then
  echo "ORAS not be found. Please install it: snap install oras --classic"
  exit 1
fi

# Pull and push the Trivy Java DB image
function handle_image() {
  local source_image="$1"
  local target_image="$2"

  echo "Pulling image: $source_image"
  oras pull "$source_image"
  if [ $? -ne 0 ]; then
    echo "Failed to pull image: $source_image"
    exit 1
  fi

  echo "Pushing image to local registry: $target_image"
  oras cp --from-insecure "$source_image" --to-plain-http "$target_image"
  if [ $? -ne 0 ]; then
    echo "Failed to push image to local registry: $target_image"
    exit 1
  fi

  echo "Successfully processed image: $source_image -> $target_image"
}

# Process the Trivy Java DB image
handle_image "$JAVA_DB_IMAGE" "$LOCAL_REGISTRY/trivy-java-db:1"

# Process the Trivy DB image
handle_image "$TRIVY_DB_IMAGE" "$LOCAL_REGISTRY/trivy-db:2"

echo "All images have been successfully pulled and pushed."
