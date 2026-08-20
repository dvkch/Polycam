#!/bin/bash
set -e

TARGET="${1:-all}"

usage() {
    echo "Usage: $0 [macos-arm64|macos-x86_64|linux-arm64|linux-amd64|all]"
    exit 1
}

case "$TARGET" in
    macos-arm64|macos-x86_64|linux-arm64|linux-amd64|all) ;;
    *) usage ;;
esac

mkdir -p build/

build_macos_arm64() {
    echo ""
    echo "Building for macOS ARM64..."
    # can't build for both archs in one go, cf https://github.com/swiftlang/swift-package-manager/issues/8013
    swift build --arch arm64 -c release -Xswiftc -O
    rm -rf "build/macOS-arm64"
    mkdir -p "build/macOS-arm64"
    cp ".build/arm64-apple-macosx/release/ptz" "build/macOS-arm64/"
}

build_macos_x86_64() {
    echo ""
    echo "Building for macOS x64..."
    swift build --arch x86_64 -c release -Xswiftc -O
    rm -rf "build/macOS-x86_64"
    mkdir -p "build/macOS-x86_64"
    cp ".build/x86_64-apple-macosx/release/ptz" "build/macOS-x86_64/"
}

build_linux_arm64() {
    if ! command -v docker &> /dev/null; then
        echo "Couldn't build for linux, docker isn't available"
        exit 1
    fi
    BUILD_CMD="apt update && apt install -y libncurses5-dev && swift build -c release -Xswiftc -O -Xswiftc -static-stdlib -Xlinker -s"
    echo ""
    echo "Building for Linux ARM64..."
    docker container rm -f SwiftPTZ-linux-arm64 > /dev/null 2>&1 || true
    docker run -it --name SwiftPTZ-linux-arm64 --platform linux/arm64/v8 -v $(pwd):/sources swift:6.0-jammy /bin/bash -c "cd sources && $BUILD_CMD"
    rm -rf "build/linux-arm64"
    mkdir -p "build/linux-arm64"
    cp ".build/aarch64-unknown-linux-gnu/release/ptz" "build/linux-arm64/"
}

build_linux_amd64() {
    if ! command -v docker &> /dev/null; then
        echo "Couldn't build for linux, docker isn't available"
        exit 1
    fi
    BUILD_CMD="apt update && apt install -y libncurses5-dev && swift build -c release -Xswiftc -O -Xswiftc -static-stdlib -Xlinker -s"
    echo ""
    echo "Building for Linux x64..."
    docker container rm -f SwiftPTZ-linux-amd64 > /dev/null 2>&1 || true
    docker run -it --name SwiftPTZ-linux-amd64 --platform linux/amd64 -v $(pwd):/sources swift:6.0-jammy /bin/bash -c "cd sources && $BUILD_CMD"
    rm -rf "build/linux-amd64"
    mkdir -p "build/linux-amd64"
    cp ".build/x86_64-unknown-linux-gnu/release/ptz" "build/linux-amd64/"
}

case "$TARGET" in
    macos-arm64)   build_macos_arm64 ;;
    macos-x86_64)  build_macos_x86_64 ;;
    linux-arm64)   build_linux_arm64 ;;
    linux-amd64)   build_linux_amd64 ;;
    all)
        build_macos_arm64
        build_macos_x86_64
        build_linux_arm64
        build_linux_amd64
        ;;
esac

echo ""
echo "Archiving"
find build/ -maxdepth 1 -mindepth 1 -type d -exec zip -r {}.zip {} \;
echo "All good!"
