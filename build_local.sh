#!/bin/bash
set -e

# Configuration
VERSION=$(grep -v '^#' upstream-version.txt | xargs)
SRC_DIR="simplelogin-src"
IMAGE_NAME="simplelogin:local"
ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')

echo "🚀 Starting build for SimpleLogin $VERSION on $ARCH..."

rm -rf "$SRC_DIR"
git clone --depth 1 --branch "$VERSION" https://github.com/simple-login/app.git "$SRC_DIR"

# Copy the Dockerfile from the ROOT of your current repo into the source dir
cp Dockerfile "./$SRC_DIR/"

cd "$SRC_DIR"
podman build \
  --build-arg TARGETARCH="$ARCH" \
  -f Dockerfile \
  -t "$IMAGE_NAME" .

rm -rf ./$SRC_DIR

echo "✅ Build complete: $IMAGE_NAME"