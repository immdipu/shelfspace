#!/bin/bash

# ShelfSpace GitHub Release Creation Script
# This script helps you create a GitHub release with the built DMG

set -e

# Load version configuration
if [ -f "version.conf" ]; then
    source version.conf
else
    echo "❌ version.conf not found"
    exit 1
fi

echo "🚀 Creating GitHub Release for ShelfSpace v$APP_VERSION"
echo "=================================================="

# Check if we have the built files
DMG_FILE="dist/$APP_NAME-$APP_VERSION.dmg"
CHECKSUM_FILE="dist/$APP_NAME-$APP_VERSION.dmg.sha256"
RELEASE_INFO_FILE="dist/RELEASE_INFO.txt"

if [ ! -f "$DMG_FILE" ]; then
    echo "❌ DMG file not found: $DMG_FILE"
    echo "💡 Run './release.sh' first to build the DMG"
    exit 1
fi

if [ ! -f "$CHECKSUM_FILE" ]; then
    echo "❌ Checksum file not found: $CHECKSUM_FILE"
    echo "💡 Run './release.sh' first to generate checksums"
    exit 1
fi

echo "✅ Found all required files:"
echo "   📦 DMG: $DMG_FILE"
echo "   🔐 Checksum: $CHECKSUM_FILE"
echo "   📄 Release Info: $RELEASE_INFO_FILE"
echo ""

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Not in a git repository"
    exit 1
fi

# Check if we have uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  You have uncommitted changes. Commit them first:"
    git status --porcelain
    echo ""
    read -p "Do you want to continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if tag already exists
if git rev-parse "v$APP_VERSION" >/dev/null 2>&1; then
    echo "⚠️  Tag v$APP_VERSION already exists"
    read -p "Do you want to delete it and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git tag -d "v$APP_VERSION"
        git push origin --delete "v$APP_VERSION" 2>/dev/null || true
    else
        exit 1
    fi
fi

echo "📝 Creating git tag v$APP_VERSION..."
git tag -a "v$APP_VERSION" -m "ShelfSpace v$APP_VERSION

Features:
• Lightweight temporary file and clipboard manager
• Drag & drop files up to 200MB
• Automatic screenshot detection
• Copy/paste text and images
• Smart file categorization
• Pin important items

System Requirements:
- macOS 13.0 (Ventura) or later
- Intel or Apple Silicon Mac"

echo "🚀 Pushing tag to GitHub..."
git push origin "v$APP_VERSION"

echo ""
echo "🎉 RELEASE PROCESS INITIATED!"
echo "=================================================="
echo "✅ Git tag v$APP_VERSION created and pushed"
echo "🔄 GitHub Actions will now build and create the release automatically"
echo ""
echo "📍 Next steps:"
echo "1. Go to: https://github.com/immdipu/shelfspace/actions"
echo "2. Wait for the 'Build and Release ShelfSpace' workflow to complete"
echo "3. Check the release at: https://github.com/immdipu/shelfspace/releases"
echo ""
echo "📦 Manual release option:"
echo "If the automated release fails, you can create it manually at:"
echo "https://github.com/immdipu/shelfspace/releases/new?tag=v$APP_VERSION"
echo ""
echo "🔗 Files to upload manually (if needed):"
echo "   - $DMG_FILE"
echo "   - $CHECKSUM_FILE"
echo "   - $RELEASE_INFO_FILE"
