#!/bin/bash
set -e

# Configuration
VERSION=$(grep -v '^#' upstream-version.txt | xargs)
SRC_DIR="simplelogin-src"
IMAGE_NAME="simplelogin:local"
ARCH=$(uname -m | sed 's/x86_64/amd64/' | sed 's/aarch64/arm64/')
APPLY_PATCH=false
NODE_VERSION="10.17.0"

# Simple flag check
if [[ "$1" == "--patch" ]]; then
  APPLY_PATCH=true
  IMAGE_NAME="simplelogin:local-modern-ui"
  NODE_VERSION="24"
fi

echo "🚀 Starting build for SimpleLogin $VERSION on $ARCH (Patch: $APPLY_PATCH, Node: $NODE_VERSION)..."

rm -rf "$SRC_DIR"
git clone --depth 1 --branch "$VERSION" https://github.com/simple-login/app.git "$SRC_DIR"

if [[ "$APPLY_PATCH" == "true" ]]; then
  echo "🩹 Applying modern-ui.patch..."
  cd "$SRC_DIR"
  git apply ../modern-ui.patch
  cd ..
fi

# Copy the Dockerfile from the ROOT of your current repo into the source dir
cp Dockerfile "./$SRC_DIR/"

cd "$SRC_DIR"
podman build \
  --build-arg TARGETARCH="$ARCH" \
  --build-arg NODE_VERSION="$NODE_VERSION" \
  -f Dockerfile \
  -t "$IMAGE_NAME" .

cd ..
rm -rf "$SRC_DIR"

echo "✅ Build complete: $IMAGE_NAME"