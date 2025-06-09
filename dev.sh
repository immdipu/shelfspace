#!/bin/bash

# FileShelf Development Helper Script

set -e

case "$1" in
    "build")
        echo "🔨 Building in debug mode..."
        export DEVELOPER_DIR=/Library/Developer/CommandLineTools
        swift build
        ;;
    "run")
        echo "🚀 Building and running ShelfSpace..."
        export DEVELOPER_DIR=/Library/Developer/CommandLineTools
        swift build
        .build/debug/ShelfSpace
        ;;
    "release")
        echo "📦 Creating release build..."
        ./build.sh
        ;;
    "test")
        echo "🧪 Running tests..."
        swift test
        ;;
    "clean")
        echo "🧹 Cleaning build artifacts..."
        rm -rf .build
        rm -rf ShelfSpace.app
        echo "✅ Clean complete!"
        ;;
    "install")
        echo "📲 Installing to Applications..."
        if [ ! -d "ShelfSpace.app" ]; then
            echo "⚠️  ShelfSpace.app not found. Building first..."
            ./build.sh
        fi
        cp -r ShelfSpace.app /Applications/
        echo "✅ Installed to /Applications/ShelfSpace.app"
        ;;
    "debug")
        echo "🐛 Starting with debugging..."
        export DEVELOPER_DIR=/Library/Developer/CommandLineTools
        swift build
        lldb .build/debug/ShelfSpace
        ;;
    *)
        echo "ShelfSpace Development Helper"
        echo ""
        echo "Usage: ./dev.sh [command]"
        echo ""
        echo "Commands:"
        echo "  build     - Build in debug mode"
        echo "  run       - Build and run the app"
        echo "  release   - Create release build (.app bundle)"
        echo "  test      - Run tests"
        echo "  clean     - Clean build artifacts"
        echo "  install   - Install to Applications folder"
        echo "  debug     - Start with LLDB debugger"
        echo ""
        echo "Examples:"
        echo "  ./dev.sh build    # Quick debug build"
        echo "  ./dev.sh run      # Build and run"
                  echo "  ./dev.sh release  # Create ShelfSpace.app"
        ;;
esac 