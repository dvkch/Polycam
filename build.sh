#!/bin/bash

set -e

# Cleanup
#rm -rf .build/ build/

# Install dependencies if need be
check_ncurses_debian() {
    if dpkg -s libncurses5-dev &> /dev/null || dpkg -s libncurses-dev &> /dev/null; then
        echo "libncurses5-dev is already installed."
    else
        read -p "libncurses5-dev is not installed. Do you want to install it? (y/n) " answer
        case "$answer" in
            [Yy]* )
                echo "Installing libncurses5-dev..."
                sudo apt update
                sudo apt install -y libncurses5-dev
                ;;
            * )
                echo "Skipping installation. Exiting script."
                exit 1
                ;;
        esac
    fi
}

OS_TYPE="$(uname)"
if [[ "$OS_TYPE" == "Darwin" ]]; then
    # macOS
    echo "Running on macOS. Continuing script..."
elif [[ "$OS_TYPE" == "Linux" ]]; then
    # Check if apt exists (Debian-based)
    if command -v apt &> /dev/null; then
        check_ncurses_debian
    else
        echo "Non-Debian Linux detected. Aborting script."
        exit 1
    fi
else
    echo "Unsupported OS ($OS_TYPE). Aborting script."
    exit 1
fi

# Build for platform
echo ""
echo "Building for current platform..."
swift build -c release -Xswiftc -O
cp ".build/*/release/ptz" "ptz"
echo "Make sure libncurses5-dev is available"

echo ""
echo "All good! `ptz` is now available"
