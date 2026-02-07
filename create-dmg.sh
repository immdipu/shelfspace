#!/bin/bash

# ShelfSpace DMG Creation Script
# Creates a DMG with the classic "drag to Applications" layout

set -e

# Load version configuration
if [ -f "version.conf" ]; then
    source version.conf
    echo "📋 Loaded version configuration"
else
    echo "⚠️  version.conf not found, using defaults"
    APP_NAME="ShelfSpace"
    APP_VERSION="1.0.0"
fi

DMG_NAME="${APP_NAME}-${APP_VERSION}"
VOLUME_NAME="$APP_NAME"
DIST_DIR="dist"
FINAL_DMG="$DIST_DIR/$DMG_NAME.dmg"

echo "📦 Creating DMG installer for $APP_NAME v$APP_VERSION..."

# Check if app exists
if [ ! -d "$APP_NAME.app" ]; then
    echo "❌ Error: $APP_NAME.app not found. Run ./build.sh first."
    exit 1
fi

# Create distribution directory
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

# Create temporary staging directory with just the app and Applications symlink
STAGING="$DIST_DIR/_staging"
mkdir -p "$STAGING"
cp -R "$APP_NAME.app" "$STAGING/"
ln -s /Applications "$STAGING/Applications"

APP_SIZE=$(du -sm "$APP_NAME.app" | cut -f1)
echo "📏 App size: ${APP_SIZE}MB"

# Create compressed DMG directly from staging
echo "🔨 Creating DMG..."
hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$STAGING" \
    -ov \
    -format UDZO \
    "$FINAL_DMG"

rm -rf "$STAGING"

# Apply Finder layout by mounting the DMG and using AppleScript
echo "🎨 Applying Finder window layout..."
MOUNT_OUTPUT=$(hdiutil attach "$FINAL_DMG" -noverify -noautoopen 2>&1 || true)
MOUNT_POINT=$(echo "$MOUNT_OUTPUT" | grep -o '/Volumes/.*' | head -1)

if [ -n "$MOUNT_POINT" ]; then
    osascript <<APPLESCRIPT || true
tell application "Finder"
    tell disk "$VOLUME_NAME"
        open
        set current view of container window to icon view
        set toolbar visible of container window to false
        set statusbar visible of container window to false
        set bounds of container window to {200, 150, 740, 470}

        set viewOptions to the icon view options of container window
        set arrangement of viewOptions to not arranged
        set icon size of viewOptions to 80

        set position of item "$APP_NAME.app" of container window to {135, 150}
        set position of item "Applications" of container window to {405, 150}

        close
        open
        delay 1
        close
    end tell
end tell
APPLESCRIPT

    sleep 2
    hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || hdiutil detach "$MOUNT_POINT" -force 2>/dev/null || true
    echo "   ✅ Layout applied"
else
    echo "   ⚠️  Could not mount for layout (DMG still works)"
fi

# Create version-less copy for stable download URL
cp "$FINAL_DMG" "$DIST_DIR/$APP_NAME.dmg"

DMG_FILE_SIZE=$(du -h "$FINAL_DMG" | cut -f1)

echo ""
echo "✅ DMG created successfully!"
echo "📦 Versioned:  $FINAL_DMG"
echo "📦 Stable URL: $DIST_DIR/$APP_NAME.dmg"
echo "📏 Size: $DMG_FILE_SIZE"
echo ""
echo "To test: open $FINAL_DMG"
