#!/bin/bash

# ShelfSpace GitHub Release Creation Script
# Creates a GitHub release with the built DMG using `gh` CLI

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

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "💡 Install it with: brew install gh"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "❌ Not authenticated with GitHub CLI."
    echo "💡 Run: gh auth login"
    exit 1
fi

# Check if we have the built files
DMG_VERSIONED="dist/$APP_NAME-$APP_VERSION.dmg"
DMG_STABLE="dist/$APP_NAME.dmg"
CHECKSUM_FILE="dist/$APP_NAME-$APP_VERSION.dmg.sha256"

if [ ! -f "$DMG_VERSIONED" ]; then
    echo "❌ DMG file not found: $DMG_VERSIONED"
    echo "💡 Run 'make release' first to build the DMG"
    exit 1
fi

if [ ! -f "$DMG_STABLE" ]; then
    echo "⚠️  Stable DMG not found, creating copy..."
    cp "$DMG_VERSIONED" "$DMG_STABLE"
fi

echo "✅ Found release files:"
echo "   📦 $DMG_VERSIONED"
echo "   📦 $DMG_STABLE (stable download URL)"
[ -f "$CHECKSUM_FILE" ] && echo "   🔐 $CHECKSUM_FILE"
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "⚠️  You have uncommitted changes:"
    git status --porcelain
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Check if tag already exists
if git rev-parse "v$APP_VERSION" >/dev/null 2>&1; then
    echo "⚠️  Tag v$APP_VERSION already exists"
    read -p "Delete and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git tag -d "v$APP_VERSION"
        git push origin --delete "v$APP_VERSION" 2>/dev/null || true
        # Also delete the existing release if any
        gh release delete "v$APP_VERSION" --yes 2>/dev/null || true
    else
        exit 1
    fi
fi

# Create and push tag
echo "📝 Creating git tag v$APP_VERSION..."
git tag -a "v$APP_VERSION" -m "ShelfSpace v$APP_VERSION"

echo "🚀 Pushing tag to GitHub..."
git push origin "v$APP_VERSION"

# Create GitHub release with gh CLI
echo "📦 Creating GitHub release..."

RELEASE_BODY="## ShelfSpace v$APP_VERSION

A native macOS menu bar clipboard manager built with Swift.

### Features
- Smart clipboard monitoring — auto-captures images, text, and files
- Drag & drop — drop files in, drag items out to any app
- Grid & list views with 3 density levels
- Content filtering — All, Pinned, Images, Text, Files tabs
- Pin important items to protect from auto-cleanup
- Rich previews — image thumbnails, text rendering, file type icons
- Quick actions on hover with satisfying animations
- Persistent storage — survives app restarts
- Deeply customizable settings
- Native Swift performance, minimal memory footprint
- Launch at login support

### Installation
1. Download **ShelfSpace.dmg** below
2. Open the DMG file
3. Drag ShelfSpace to your Applications folder
4. Launch from Applications (right-click → Open on first launch if unsigned)

### System Requirements
- macOS 13.0 (Ventura) or later
- Intel or Apple Silicon Mac"

# Build the gh release create command with available assets
ASSETS=("$DMG_STABLE" "$DMG_VERSIONED")
[ -f "$CHECKSUM_FILE" ] && ASSETS+=("$CHECKSUM_FILE")

gh release create "v$APP_VERSION" \
    --title "ShelfSpace v$APP_VERSION" \
    --notes "$RELEASE_BODY" \
    "${ASSETS[@]}"

echo ""
echo "🎉 RELEASE PUBLISHED!"
echo "=================================================="
echo "🔗 https://github.com/immdipu/shelfspace/releases/tag/v$APP_VERSION"
echo ""
echo "📥 Direct download URL (use this on landing page):"
echo "   https://github.com/immdipu/shelfspace/releases/latest/download/ShelfSpace.dmg"
