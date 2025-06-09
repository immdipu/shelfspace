#!/bin/bash

# ShelfSpace Icon Generation Script

set -e

APP_NAME="ShelfSpace"
ICON_NAME="AppIcon"
SOURCE_ICON="icon-1024.png"
ICONSET_DIR="$ICON_NAME.iconset"

echo "🎨 Generating app icons for $APP_NAME..."

# Create iconset directory
rm -rf "$ICONSET_DIR"
mkdir "$ICONSET_DIR"

# Check if source icon exists
if [ ! -f "$SOURCE_ICON" ]; then
    echo "⚠️  Source icon not found. Creating placeholder icon..."
    
    # Create a simple placeholder icon using system tools
    cat > create_placeholder_icon.py << 'EOF'
from PIL import Image, ImageDraw, ImageFont
import sys

def create_icon():
    # Create 1024x1024 image
    size = 1024
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Create a gradient background
    for i in range(size):
        color_value = int(255 * (1 - i / size * 0.3))
        color = (47, 158, 244, 255)  # ShelfSpace blue
        draw.line([(0, i), (size, i)], fill=color)
    
    # Draw a shelf-like icon
    shelf_color = (255, 255, 255, 255)
    shelf_width = size // 15
    shelf_height = size // 8
    
    # Draw three shelves
    for i in range(3):
        y = size // 4 + i * size // 4
        draw.rectangle([size//6, y, size*5//6, y + shelf_width], fill=shelf_color)
        
        # Add some items on shelves
        item_size = shelf_width * 2
        for j in range(2):
            x = size//4 + j * size//3
            draw.rectangle([x, y - item_size, x + item_size, y], fill=(220, 220, 220, 255))
    
    img.save('icon-1024.png')
    print("Created placeholder icon: icon-1024.png")

if __name__ == "__main__":
    try:
        create_icon()
    except ImportError:
        print("PIL not available, creating simple icon with ImageMagick...")
        exit(1)
EOF

    # Try to create with Python PIL, fallback to ImageMagick
    if python3 create_placeholder_icon.py 2>/dev/null; then
        echo "✅ Created placeholder icon with Python"
    elif command -v convert >/dev/null 2>&1; then
        echo "📝 Creating placeholder icon with ImageMagick..."
        convert -size 1024x1024 xc:"#2F9EF4" \
                -fill white -stroke white -strokewidth 8 \
                -draw "rectangle 170,256 854,298" \
                -draw "rectangle 170,512 854,554" \
                -draw "rectangle 170,768 854,810" \
                -fill "#DCDCDC" \
                -draw "rectangle 256,214 342,256" \
                -draw "rectangle 512,214 598,256" \
                -draw "rectangle 256,470 342,512" \
                -draw "rectangle 512,470 598,512" \
                -draw "rectangle 256,726 342,768" \
                -draw "rectangle 512,726 598,768" \
                "$SOURCE_ICON"
        echo "✅ Created placeholder icon with ImageMagick"
    else
        echo "❌ Cannot create icon. Please provide icon-1024.png or install ImageMagick/PIL"
        exit 1
    fi
    
    rm -f create_placeholder_icon.py
fi

# Define icon sizes and their corresponding filenames
ICON_FILES=(
    "icon_16x16.png:16"
    "icon_16x16@2x.png:32"
    "icon_32x32.png:32"
    "icon_32x32@2x.png:64"
    "icon_128x128.png:128"
    "icon_128x128@2x.png:256"
    "icon_256x256.png:256"
    "icon_256x256@2x.png:512"
    "icon_512x512.png:512"
    "icon_512x512@2x.png:1024"
)

# Generate all icon sizes
for entry in "${ICON_FILES[@]}"; do
    filename="${entry%:*}"
    size="${entry#*:}"
    echo "📐 Generating $filename (${size}x${size})"
    
    if command -v sips >/dev/null 2>&1; then
        # Use macOS sips for best quality
        sips -z $size $size "$SOURCE_ICON" --out "$ICONSET_DIR/$filename" >/dev/null 2>&1
    elif command -v magick >/dev/null 2>&1; then
        # Use ImageMagick v7
        magick "$SOURCE_ICON" -resize ${size}x${size} "$ICONSET_DIR/$filename"
    elif command -v convert >/dev/null 2>&1; then
        # Fallback to ImageMagick v6
        convert "$SOURCE_ICON" -resize ${size}x${size} "$ICONSET_DIR/$filename"
    else
        echo "❌ No image processing tool found. Install ImageMagick or use macOS."
        exit 1
    fi
done

# Create .icns file
echo "🔨 Creating .icns file..."
iconutil -c icns "$ICONSET_DIR" -o "$APP_NAME.icns"

# Copy to app bundle if it exists
if [ -d "$APP_NAME.app" ]; then
    echo "📦 Installing icon to app bundle..."
    cp "$APP_NAME.icns" "$APP_NAME.app/Contents/Resources/"
    
    # Update Info.plist to reference the icon
    if [ -f "$APP_NAME.app/Contents/Info.plist" ]; then
        # Add icon reference to Info.plist
        plutil -insert CFBundleIconFile -string "$APP_NAME.icns" "$APP_NAME.app/Contents/Info.plist" 2>/dev/null || true
        plutil -insert CFBundleIconName -string "$APP_NAME" "$APP_NAME.app/Contents/Info.plist" 2>/dev/null || true
    fi
fi

# Clean up
rm -rf "$ICONSET_DIR"

echo "✅ Icons generated successfully!"
echo "📁 Created: $APP_NAME.icns"
if [ -f "$SOURCE_ICON" ]; then
    echo "📏 Source: $SOURCE_ICON ($(file "$SOURCE_ICON" | cut -d',' -f2 | xargs))"
fi
echo ""
echo "To use a custom icon:"
echo "  1. Replace icon-1024.png with your 1024x1024 PNG icon"
echo "  2. Run ./create-icons.sh again"
echo "  3. Rebuild the app with ./build.sh" 