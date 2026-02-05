#!/bin/bash

# FileShelf Development Helper Script

set -e

# Colors for pretty output
BLUE='\033[34m'
GREEN='\033[32m'
YELLOW='\033[33m'
RED='\033[31m'
RESET='\033[0m'

# Kill any existing instances of the app
kill_app() {
    pkill -f ".build/debug/ShelfSpace" 2>/dev/null || true
    sleep 0.5
}

# Build the app
build_app() {
    echo -e "${BLUE}🔨 Building in debug mode...${RESET}"
    export DEVELOPER_DIR=/Library/Developer/CommandLineTools
    swift build
}

# Run the app in background
run_app() {
    echo -e "${GREEN}🚀 Starting ShelfSpace...${RESET}"
    .build/debug/ShelfSpace &
    APP_PID=$!
    echo -e "${GREEN}📱 App started with PID: $APP_PID${RESET}"
}

# Watch for file changes and hot reload
watch_mode() {
    echo -e "${YELLOW}👁️  Starting hot reload mode...${RESET}"
    echo -e "${YELLOW}📂 Watching Sources/ for changes...${RESET}"
    echo -e "${YELLOW}🔄 Press Ctrl+C to stop${RESET}"
    echo ""
    
    # Initial build and run
    build_app && run_app
    
    # Use fswatch if available, otherwise fall back to basic polling
    if command -v fswatch >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Using fswatch for efficient file monitoring${RESET}"
        fswatch -o Sources/ | while read event; do
            echo -e "${BLUE}📝 File change detected! Rebuilding...${RESET}"
            kill_app
            if build_app; then
                run_app
                echo -e "${GREEN}🔄 Hot reload complete!${RESET}"
            else
                echo -e "${RED}❌ Build failed. Fix errors and save again.${RESET}"
            fi
        done
    else
        echo -e "${YELLOW}⚠️  fswatch not found. Install with: brew install fswatch${RESET}"
        echo -e "${YELLOW}📊 Using basic file monitoring (less efficient)${RESET}"
        
        last_modified=$(find Sources/ -name "*.swift" -exec stat -f "%m" {} \; | sort -n | tail -1)
        
        while true; do
            sleep 1
            current_modified=$(find Sources/ -name "*.swift" -exec stat -f "%m" {} \; | sort -n | tail -1)
            
            if [ "$current_modified" != "$last_modified" ]; then
                echo -e "${BLUE}📝 File change detected! Rebuilding...${RESET}"
                kill_app
                if build_app; then
                    run_app
                    echo -e "${GREEN}🔄 Hot reload complete!${RESET}"
                else
                    echo -e "${RED}❌ Build failed. Fix errors and save again.${RESET}"
                fi
                last_modified=$current_modified
            fi
        done
    fi
}

case "$1" in
    "build")
        echo -e "${BLUE}🔨 Building in debug mode...${RESET}"
        export DEVELOPER_DIR=/Library/Developer/CommandLineTools
        swift build
        ;;
    "run")
        echo -e "${GREEN}🚀 Building and running ShelfSpace...${RESET}"
        export DEVELOPER_DIR=/Library/Developer/CommandLineTools
        swift build
        .build/debug/ShelfSpace
        ;;
    "watch"|"dev")
        # Hot reload mode - watch for changes and auto-rebuild
        trap 'kill_app; exit 0' INT TERM
        watch_mode
        ;;
    "release")
        echo -e "${BLUE}📦 Creating release build...${RESET}"
        ./build.sh
        ;;
    "test")
        echo -e "${BLUE}🧪 Running tests...${RESET}"
        swift test
        ;;
    "clean")
        echo -e "${YELLOW}🧹 Cleaning build artifacts...${RESET}"
        kill_app
        rm -rf .build
        rm -rf ShelfSpace.app
        echo -e "${GREEN}✅ Clean complete!${RESET}"
        ;;
    "install")
        echo -e "${BLUE}📲 Installing to Applications...${RESET}"
        if [ ! -d "ShelfSpace.app" ]; then
            echo -e "${YELLOW}⚠️  ShelfSpace.app not found. Building first...${RESET}"
            ./build.sh
        fi
        cp -r ShelfSpace.app /Applications/
        echo -e "${GREEN}✅ Installed to /Applications/ShelfSpace.app${RESET}"
        ;;
    "debug")
        echo -e "${BLUE}🐛 Starting with debugging...${RESET}"
        export DEVELOPER_DIR=/Library/Developer/CommandLineTools
        swift build
        lldb .build/debug/ShelfSpace
        ;;
    *)
        echo -e "${GREEN}ShelfSpace Development Helper${RESET}"
        echo ""
        echo -e "${YELLOW}Usage: ./dev.sh [command]${RESET}"
        echo ""
        echo -e "${BLUE}Commands:${RESET}"
        echo "  build     - Build in debug mode"
        echo "  run       - Build and run the app"
        echo "  watch/dev - 🔥 Hot reload mode (auto-rebuild on file changes)"
        echo "  release   - Create release build (.app bundle)"
        echo "  test      - Run tests"
        echo "  clean     - Clean build artifacts"
        echo "  install   - Install to Applications folder"
        echo "  debug     - Start with LLDB debugger"
        echo ""
        echo -e "${BLUE}Examples:${RESET}"
        echo "  ./dev.sh build    # Quick debug build"
        echo "  ./dev.sh run      # Build and run"
        echo "  ./dev.sh watch    # 🔥 Hot reload development mode"
        echo "  ./dev.sh release  # Create ShelfSpace.app"
        echo ""
        echo -e "${GREEN}💡 For the best development experience, use:${RESET}"
        echo -e "   ${YELLOW}./dev.sh watch${RESET}   # Automatically rebuilds when you save files!"
        ;;
esac 