# ShelfSpace Build Documentation

## Overview

ShelfSpace is a macOS menu bar application built with Swift Package Manager. This document explains how to build, package, and distribute the application.

## Prerequisites

- macOS 13.0 or later
- Xcode Command Line Tools (`xcode-select --install`)
- Swift 5.9 or later
- Optional: Developer ID certificate for code signing

## Project Structure

```
ShelfSpace/
├── Sources/                    # Swift source code
├── build.sh                    # Main build script
├── create-icons.sh            # Icon generation script
├── create-dmg.sh              # DMG creation script
├── release.sh                 # Complete release pipeline
├── version.conf               # Version configuration
├── ShelfSpace.entitlements    # App entitlements
├── Package.swift              # Swift Package Manager config
└── icon-1024.png             # Source icon (optional)
```

## Building the App

### Quick Build

```bash
./build.sh
```

This creates `ShelfSpace.app` ready for local testing.

### Complete Release Build

```bash
./release.sh
```

This runs the complete pipeline:

1. Generates app icons
2. Builds the application
3. Signs the app (if certificate available)
4. Creates DMG installer
5. Generates checksums and release info

## Individual Scripts

### Icon Generation

```bash
./create-icons.sh
```

- Creates app icons from `icon-1024.png`
- Generates all required icon sizes
- Creates `ShelfSpace.icns` file
- If no source icon exists, creates a placeholder

### DMG Creation

```bash
./create-dmg.sh
```

- Creates professional DMG installer
- Includes drag-to-Applications setup
- Adds README and proper layout

## Version Management

Edit `version.conf` to update app version:

```bash
APP_VERSION="1.1.0"          # Semantic version
BUNDLE_ID="com.your.id"      # Bundle identifier
DEVELOPER_NAME="Your Name"    # Copyright holder
```

All scripts automatically use these settings.

## Code Signing

### Development

Apps are unsigned by default. Users need to right-click and select "Open" on first launch.

### Distribution

To sign for distribution:

1. Get a Developer ID certificate from Apple
2. Install in Keychain
3. Run `./release.sh` - it automatically detects and uses the certificate

The app will be signed with Hardened Runtime and notarization-ready entitlements.

## App Store Distribution

For App Store distribution:

1. Change `LSUIElement` to `false` in build.sh
2. Enable app sandboxing in entitlements
3. Use Xcode for final submission

## File Structure Details

### App Bundle (`ShelfSpace.app/`)

```
ShelfSpace.app/
├── Contents/
│   ├── Info.plist           # App metadata
│   ├── PkgInfo              # Package type
│   ├── MacOS/
│   │   └── ShelfSpace       # Executable
│   └── Resources/
│       └── ShelfSpace.icns  # App icon
```

### Distribution (`dist/`)

```
dist/
├── ShelfSpace-1.0.0.dmg         # DMG installer
├── ShelfSpace-1.0.0.dmg.sha256  # Checksum
└── RELEASE_INFO.txt             # Release notes
```

## Customization

### App Icon

1. Replace `icon-1024.png` with your 1024×1024 PNG icon
2. Run `./create-icons.sh`
3. Rebuild with `./build.sh`

### App Metadata

Edit the Info.plist generation in `build.sh`:

- Bundle name and display name
- Copyright information
- System requirements
- Document types

### DMG Appearance

Modify `create-dmg.sh`:

- Window size and layout
- Icon positions
- Background image
- Volume name

## Testing

### Local Testing

```bash
./build.sh
open ShelfSpace.app
```

### DMG Testing

```bash
./create-dmg.sh
open dist/ShelfSpace-1.0.0.dmg
```

## Troubleshooting

### Build Failures

- Ensure Command Line Tools are installed
- Check Swift version: `swift --version`
- Verify permissions on scripts: `chmod +x *.sh`

### Signing Issues

- Check certificate: `security find-identity -v -p codesigning`
- Verify entitlements file exists
- Use Keychain Access to verify certificate installation

### DMG Creation Failures

- Ensure sufficient disk space
- Check if previous DMG is mounted
- Verify app bundle exists and is valid

## Distribution Checklist

- [ ] Update version in `version.conf`
- [ ] Test app functionality
- [ ] Run complete build: `./release.sh`
- [ ] Test DMG on clean Mac
- [ ] Create GitHub release
- [ ] Upload DMG and checksums
- [ ] Update documentation

## Support

For build issues:

1. Check this documentation
2. Verify all prerequisites
3. Test individual scripts
4. File issue on GitHub with build logs
