#!/bin/bash

# ShelfSpace - macOS Menu Bar App Build Script

set -e

# Load version configuration
if [ -f "version.conf" ]; then
    source version.conf
    echo "📋 Loaded version configuration"
else
    echo "⚠️  version.conf not found, using defaults"
    APP_NAME="ShelfSpace"
    APP_VERSION="1.0.0"
    BUNDLE_ID="com.dipuchaurasiya.shelfspace"
    DEVELOPER_NAME="Dipu Chaurasiya"
    COPYRIGHT_YEAR=$(date +%Y)
    MIN_MACOS_VERSION="13.0"
fi

BUILD_NUMBER=$(date +%Y%m%d%H%M)

echo "🚀 Building $APP_NAME v$APP_VERSION (Build $BUILD_NUMBER)..."

# Clean previous build
rm -rf .build
rm -rf "$APP_NAME.app"
rm -rf dist

# Build with Swift Package Manager
export DEVELOPER_DIR=/Library/Developer/CommandLineTools
swift build -c release

# Create app bundle structure
mkdir -p "$APP_NAME.app/Contents/MacOS"
mkdir -p "$APP_NAME.app/Contents/Resources"
mkdir -p "$APP_NAME.app/Contents/Frameworks"

# Copy executable
cp ".build/release/$APP_NAME" "$APP_NAME.app/Contents/MacOS/"

# Create comprehensive Info.plist
cat > "$APP_NAME.app/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>$BUNDLE_ID</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleVersion</key>
    <string>$BUILD_NUMBER</string>
    <key>CFBundleShortVersionString</key>
    <string>$APP_VERSION</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>LSUIElement</key>
    <true/>
    <key>LSMinimumSystemVersion</key>
    <string>$MIN_MACOS_VERSION</string>
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © $COPYRIGHT_YEAR $DEVELOPER_NAME. All rights reserved.</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSSupportsAutomaticGraphicsSwitching</key>
    <true/>
    <key>NSRequiresAquaSystemAppearance</key>
    <false/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.utilities</string>
    <key>NSDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeName</key>
            <string>All Files</string>
            <key>CFBundleTypeRole</key>
            <string>Viewer</string>
            <key>LSTypeIsPackage</key>
            <false/>
            <key>NSDocumentClass</key>
            <string>NSDocument</string>
        </dict>
    </array>
    <key>UTExportedTypeDeclarations</key>
    <array>
        <dict>
            <key>UTTypeIdentifier</key>
            <string>$BUNDLE_ID.document</string>
            <key>UTTypeDescription</key>
            <string>ShelfSpace Document</string>
            <key>UTTypeConformsTo</key>
            <array>
                <string>public.data</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

# Create PkgInfo file
echo "APPL????" > "$APP_NAME.app/Contents/PkgInfo"

# Add icon to Info.plist if it exists
if [ -f "$APP_NAME.icns" ]; then
    echo "🎨 Installing app icon..."
    cp "$APP_NAME.icns" "$APP_NAME.app/Contents/Resources/"
    
    # Update Info.plist to reference the icon
    plutil -insert CFBundleIconFile -string "$APP_NAME.icns" "$APP_NAME.app/Contents/Info.plist" 2>/dev/null || true
    plutil -insert CFBundleIconName -string "$APP_NAME" "$APP_NAME.app/Contents/Info.plist" 2>/dev/null || true
    echo "✅ App icon installed"
else
    echo "⚠️  No app icon found. Run ./create-icons.sh first for a custom icon."
fi

echo "✅ Build complete! $APP_NAME.app v$APP_VERSION created."
echo "📦 Bundle ID: $BUNDLE_ID"
echo "🔨 Build Number: $BUILD_NUMBER"
echo ""
echo "To run the app:"
echo "  open $APP_NAME.app"
echo ""
echo "To install to Applications:"
echo "  cp -r $APP_NAME.app /Applications/"
echo ""
echo "To create DMG, run:"
echo "  ./create-dmg.sh" 