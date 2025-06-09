#!/bin/bash

# ShelfSpace - macOS Menu Bar App Build Script

set -e

echo "🚀 Building ShelfSpace..."

# Clean previous build
rm -rf .build
rm -rf ShelfSpace.app

# Build with Swift Package Manager
export DEVELOPER_DIR=/Library/Developer/CommandLineTools
swift build -c release

# Create app bundle structure
mkdir -p ShelfSpace.app/Contents/MacOS
mkdir -p ShelfSpace.app/Contents/Resources

# Copy executable
cp .build/release/ShelfSpace ShelfSpace.app/Contents/MacOS/

# Create Info.plist
cat > ShelfSpace.app/Contents/Info.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>ShelfSpace</string>
    <key>CFBundleIdentifier</key>
    <string>com.dipuchaurasiya.shelfspace</string>
    <key>CFBundleName</key>
    <string>ShelfSpace</string>
    <key>CFBundleDisplayName</key>
    <string>ShelfSpace</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2024 Dipu Chaurasiya. All rights reserved.</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
</dict>
</plist>
EOF

echo "✅ Build complete! ShelfSpace.app created."
echo ""
echo "To run the app:"
echo "  open ShelfSpace.app"
echo ""
echo "To install to Applications:"
echo "  cp -r ShelfSpace.app /Applications/" 