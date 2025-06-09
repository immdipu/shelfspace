#!/bin/bash

# ShelfSpace DMG Creation Script

set -e

# Load version configuration
if [ -f "version.conf" ]; then
    source version.conf
    echo "📋 Loaded version configuration"
else
    echo "⚠️  version.conf not found, using defaults"
    APP_NAME="ShelfSpace"
    APP_VERSION="1.0.0"
    GITHUB_URL="https://github.com/immdipu"
fi

DMG_NAME="${APP_NAME}-${APP_VERSION}"
VOLUME_NAME="$APP_NAME $APP_VERSION"
DMG_BACKGROUND="dmg-background.png"
DIST_DIR="dist"

echo "📦 Creating DMG installer for $APP_NAME v$APP_VERSION..."

# Check if app exists
if [ ! -d "$APP_NAME.app" ]; then
    echo "❌ Error: $APP_NAME.app not found. Run ./build.sh first."
    exit 1
fi

# Create distribution directory
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Create temporary DMG directory
TEMP_DMG_DIR="$DIST_DIR/dmg_temp"
mkdir -p "$TEMP_DMG_DIR"

# Copy app to temp directory
cp -R "$APP_NAME.app" "$TEMP_DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$TEMP_DMG_DIR/Applications"

# Create README file for the DMG
cat > "$TEMP_DMG_DIR/README.txt" << EOF
ShelfSpace v$APP_VERSION

Installation Instructions:
1. Drag ShelfSpace.app to the Applications folder
2. Launch ShelfSpace from Applications or Launchpad
3. Grant necessary permissions when prompted

Features:
• Lightweight temporary file and clipboard manager
• Drag & drop files up to 200MB
• Automatic screenshot detection
• Copy/paste text and images
• Smart file categorization
• Pin important items

For support and updates, visit:
$GITHUB_URL

Copyright © $(date +%Y) Dipu Chaurasiya. All rights reserved.
EOF

# Calculate size needed for DMG (app size + 50MB buffer)
APP_SIZE=$(du -sm "$APP_NAME.app" | cut -f1)
DMG_SIZE=$((APP_SIZE + 50))

echo "📏 App size: ${APP_SIZE}MB, DMG size: ${DMG_SIZE}MB"

# Create DMG directly from the temp directory
echo "🔨 Creating DMG..."
hdiutil create -volname "$VOLUME_NAME" -srcfolder "$TEMP_DMG_DIR" -ov -format UDZO "$DIST_DIR/$DMG_NAME.dmg"

# Clean up
rm -rf "$TEMP_DMG_DIR"

# Get final DMG size
DMG_FILE_SIZE=$(du -h "$DIST_DIR/$DMG_NAME.dmg" | cut -f1)

echo "✅ DMG created successfully!"
echo "📦 File: $DIST_DIR/$DMG_NAME.dmg"
echo "📏 Size: $DMG_FILE_SIZE"
echo ""
echo "To test the DMG:"
echo "  open $DIST_DIR/$DMG_NAME.dmg"
echo ""
echo "To distribute:"
echo "  Upload $DIST_DIR/$DMG_NAME.dmg to your preferred distribution platform" 