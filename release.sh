#!/bin/bash

# ShelfSpace Release Script
# This script builds the complete app with icons and creates a DMG for distribution

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
    DEVELOPER_NAME="Dipu Chaurasiya"
    MIN_MACOS_VERSION="13.0"
fi

echo "🚀 Starting ShelfSpace v$APP_VERSION release process..."
echo "=================================================="

# Step 1: Generate icons
echo ""
echo "Step 1: Generating app icons..."
chmod +x create-icons.sh
./create-icons.sh

# Step 2: Build the app
echo ""
echo "Step 2: Building the application..."
chmod +x build.sh
./build.sh

# Step 3: Code signing (if developer certificate is available)
echo ""
echo "Step 3: Code signing..."
if security find-identity -v -p codesigning | grep -q "Developer ID Application"; then
    echo "🔐 Developer certificate found, signing app..."
    
    # Sign the app bundle
    codesign --force --options runtime --entitlements ShelfSpace.entitlements --sign "Developer ID Application" "$APP_NAME.app"
    
    echo "✅ App signed successfully"
else
    echo "⚠️  No Developer ID certificate found. App will be unsigned."
    echo "   Users will need to right-click and select 'Open' on first launch."
fi

# Step 4: Verify the app
echo ""
echo "Step 4: Verifying app bundle..."
if [ -d "$APP_NAME.app" ]; then
    echo "✅ App bundle exists"
    
    # Check if executable exists and is executable
    if [ -x "$APP_NAME.app/Contents/MacOS/$APP_NAME" ]; then
        echo "✅ Executable is present and executable"
    else
        echo "❌ Executable missing or not executable"
        exit 1
    fi
    
    # Check if Info.plist exists
    if [ -f "$APP_NAME.app/Contents/Info.plist" ]; then
        echo "✅ Info.plist is present"
        # Validate plist
        plutil -lint "$APP_NAME.app/Contents/Info.plist" > /dev/null 2>&1
        echo "✅ Info.plist is valid"
    else
        echo "❌ Info.plist missing"
        exit 1
    fi
    
    # Check if icon exists
    if [ -f "$APP_NAME.app/Contents/Resources/$APP_NAME.icns" ]; then
        echo "✅ App icon is present"
    else
        echo "⚠️  App icon missing"
    fi
    
    # Get app bundle size
    APP_SIZE=$(du -sh "$APP_NAME.app" | cut -f1)
    echo "📦 App bundle size: $APP_SIZE"
    
else
    echo "❌ App bundle not found"
    exit 1
fi

# Step 5: Create DMG
echo ""
echo "Step 5: Creating DMG installer..."
chmod +x create-dmg.sh
./create-dmg.sh

# Step 6: Final verification
echo ""
echo "Step 6: Final verification..."
DMG_FILE="dist/$APP_NAME-$APP_VERSION.dmg"
if [ -f "$DMG_FILE" ]; then
    DMG_SIZE=$(du -sh "$DMG_FILE" | cut -f1)
    echo "✅ DMG created successfully"
    echo "📦 DMG size: $DMG_SIZE"
    
    # Test mount the DMG
    echo "🧪 Testing DMG mount..."
    MOUNT_POINT=$(hdiutil attach "$DMG_FILE" | grep "/Volumes/" | cut -d$'\t' -f3)
    if [ -d "$MOUNT_POINT/$APP_NAME.app" ]; then
        echo "✅ DMG mounts correctly and contains app"
        hdiutil detach "$MOUNT_POINT" > /dev/null 2>&1
    else
        echo "❌ DMG mount test failed"
        hdiutil detach "$MOUNT_POINT" > /dev/null 2>&1 || true
        exit 1
    fi
else
    echo "❌ DMG creation failed"
    exit 1
fi

# Step 7: Generate release information
echo ""
echo "Step 7: Generating release information..."
cat > dist/RELEASE_INFO.txt << EOF
ShelfSpace v$APP_VERSION Release Information
=========================================

Build Date: $(date)
App Bundle: $APP_NAME.app ($APP_SIZE)
DMG Installer: $APP_NAME-$APP_VERSION.dmg ($DMG_SIZE)

System Requirements:
- macOS $MIN_MACOS_VERSION or later
- Intel or Apple Silicon Mac

Installation:
1. Download $APP_NAME-$APP_VERSION.dmg
2. Open the DMG file
3. Drag ShelfSpace.app to Applications folder
4. Launch from Applications or Launchpad

First Launch:
- If unsigned, right-click the app and select "Open"
- Grant necessary permissions when prompted

Features:
• Lightweight temporary file and clipboard manager
• Drag & drop files up to 200MB
• Automatic screenshot detection
• Copy/paste text and images
• Smart file categorization
• Pin important items

Support:
- GitHub: $GITHUB_URL
- Issues: Report bugs and feature requests on GitHub

Copyright © $(date +%Y) Dipu Chaurasiya. All rights reserved.
EOF

# Step 8: Create checksums for security
echo ""
echo "Step 8: Creating checksums..."
cd dist
shasum -a 256 "$APP_NAME-$APP_VERSION.dmg" > "$APP_NAME-$APP_VERSION.dmg.sha256"
echo "✅ SHA256 checksum created"
cd ..

# Final summary
echo ""
echo "🎉 RELEASE COMPLETE!"
echo "=================================================="
echo "📦 App Bundle: $APP_NAME.app"
echo "💿 DMG Installer: dist/$APP_NAME-$APP_VERSION.dmg"
echo "📄 Release Info: dist/RELEASE_INFO.txt"
echo "🔐 Checksum: dist/$APP_NAME-$APP_VERSION.dmg.sha256"
echo ""
echo "Ready for distribution! 🚀"
echo ""
echo "Next steps:"
echo "1. Test the DMG on a clean Mac"
echo "2. Upload to your distribution platform"
echo "3. Update your GitHub releases"
echo "4. Update documentation if needed" 