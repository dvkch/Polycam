#!/bin/bash

set -e

# Cleanup
#rm -rf .build/ build/

# Build for macOS
# can't build for both archs in one go, cf https://github.com/swiftlang/swift-package-manager/issues/8013
echo ""
echo "Building for macOS ARM64..."
swift build --arch arm64 -c release -Xswiftc -O
mkdir -p "build/macOS-arm64"
cp ".build/arm64-apple-macosx/release/ptz" "build/macOS-arm64/"

echo ""
echo "Building for macOS x64..."
swift build --arch x86_64 -c release -Xswiftc -O
mkdir -p "build/macOS-x86_64"
cp ".build/x86_64-apple-macosx/release/ptz" "build/macOS-x86_64/"

# Build for linux
if ! command -v docker &> /dev/null; then
    echo "Couldn't build for linux, docker isn't available"
    exit -1
fi

BUILD_CMD="apt update && apt install -y libncurses5-dev && swift build -c release -Xswiftc -O"

echo ""
echo "Building for Linux ARM64..."
docker container rm -f SwiftPTZ-linux > /dev/null
docker run -it --name SwiftPTZ-linux --platform linux/arm64/v8 -v $(pwd):/sources swift:6.0-jammy /bin/bash -c "cd sources && $BUILD_CMD"
mkdir -p "build/linux-arm64"
cp ".build/aarch64-unknown-linux-gnu/release/ptz" "build/linux-arm64/"

echo ""
echo "Building for Linux x64..."
docker container rm -f SwiftPTZ-linux > /dev/null
docker run -it --name SwiftPTZ-linux --platform linux/amd64    -v $(pwd):/sources swift:6.0-jammy /bin/bash -c "cd sources && $BUILD_CMD"
mkdir -p "build/linux-amd64"
cp ".build/x86_64-unknown-linux-gnu/release/ptz"  "build/linux-amd64/"

echo ""
echo "Archiving"
find build/ -maxdepth 1 -mindepth 1 -type d -exec zip -r {}.zip {}  \;

echo "All good!"
