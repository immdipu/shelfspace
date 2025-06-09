# ShelfSpace Distribution Guide

## Overview

ShelfSpace is now ready for professional distribution with a complete build and packaging system. This guide explains the distribution files and how to release the app.

## Quick Release

To create a complete release:

```bash
./release.sh
```

This creates everything you need for distribution in the `dist/` folder.

## Distribution Files

After running `./release.sh`, you'll have:

```
dist/
├── ShelfSpace-1.0.0.dmg           # Mac installer (160KB)
├── ShelfSpace-1.0.0.dmg.sha256    # Security checksum
└── RELEASE_INFO.txt               # Release documentation
```

### DMG Installer (`ShelfSpace-1.0.0.dmg`)

- **Size**: ~160KB (very compact!)
- **Contents**:
  - ShelfSpace.app (the main application)
  - Applications symlink (for drag-to-install)
  - README.txt (installation instructions)
- **Installation**: Users drag the app to Applications folder
- **First Launch**: Users may need to right-click → Open (if unsigned)

### Security Checksum (`ShelfSpace-1.0.0.dmg.sha256`)

- SHA256 hash for verifying download integrity
- Include this in your release notes
- Users can verify with: `shasum -a 256 -c ShelfSpace-1.0.0.dmg.sha256`

### Release Information (`RELEASE_INFO.txt`)

- Complete release documentation
- System requirements
- Installation instructions
- Feature list
- Support information

## App Metadata

The app includes comprehensive metadata:

### Version Information

- **Version**: 1.0.0 (user-facing)
- **Build Number**: Generated timestamp (e.g., 202506092312)
- **Bundle ID**: com.dipuchaurasiya.shelfspace

### About Dialog

- Displays version and build number
- Copyright information
- GitHub link for support
- Professional appearance

### System Integration

- **Category**: Utilities
- **System Requirements**: macOS 13.0+
- **Architecture**: Universal (Intel + Apple Silicon)
- **Menu Bar App**: Runs in background, no dock icon

## Customization

### Update Version

Edit `version.conf`:

```bash
APP_VERSION="1.1.0"          # Update version number
DEVELOPER_NAME="Your Name"    # Your name
GITHUB_URL="https://..."     # Your GitHub
```

All scripts automatically use these settings.

### Custom Icon

1. Replace `icon-1024.png` with your 1024×1024 PNG icon
2. Run `./create-icons.sh`
3. Rebuild with `./build.sh`

### App Signing

For signed distribution:

1. Get Apple Developer ID certificate
2. Install in Keychain
3. Run `./release.sh` - automatically detects and signs

## Distribution Platforms

### GitHub Releases

1. Create new release on GitHub
2. Upload `ShelfSpace-1.0.0.dmg`
3. Include `RELEASE_INFO.txt` in description
4. Add checksum for security

### Other Platforms

The DMG works with any distribution platform:

- Direct download from website
- Mac software repositories
- Third-party app stores

## User Experience

### Installation Flow

1. User downloads DMG
2. Opens DMG file
3. Drags app to Applications
4. Launches from Launchpad/Applications
5. Grants permissions if prompted

### First Launch

- Unsigned apps require right-click → Open
- App appears in menu bar
- Ready to use immediately

### Uninstallation

- Drag app to Trash from Applications
- No system changes needed

## File Sizes

The build system creates very efficient distributions:

- **App Bundle**: ~436KB
- **DMG Installer**: ~160KB
- **Total Download**: Under 200KB

This is remarkably small for a full macOS application!

## Code Signing & Notarization

### Development (Current)

- App is unsigned
- Users need right-click → Open on first launch
- Fully functional for testing and personal use

### Production Distribution

1. **Get Developer ID**: Apply for Apple Developer Program ($99/year)
2. **Certificate**: Download Developer ID Application certificate
3. **Sign**: `./release.sh` automatically signs if certificate present
4. **Notarize**: Submit to Apple for notarization (automated in future)

### Benefits of Signing

- No "unknown developer" warnings
- Users can double-click to open
- Better security reputation
- Eligible for some app stores

## Build System Features

### Automated Pipeline

- ✅ Icon generation from source
- ✅ App bundle creation
- ✅ Metadata injection
- ✅ DMG packaging
- ✅ Checksum generation
- ✅ Release documentation

### Quality Assurance

- Validates app bundle structure
- Tests DMG mounting
- Verifies executable permissions
- Checks plist validity

### Cross-Platform

- Works on any Mac with Command Line Tools
- No Xcode required for building
- Compatible with CI/CD systems

## Maintenance

### Updating Version

1. Edit `version.conf`
2. Run `./release.sh`
3. Upload new DMG to distribution platform

### Bug Fixes

1. Update source code
2. Run `./release.sh`
3. Increment version as needed

### Feature Additions

1. Implement new features
2. Update `RELEASE_NOTES` in `version.conf`
3. Run `./release.sh`

## Support

For build or distribution issues:

- Check [BUILD.md](BUILD.md) for detailed build instructions
- Verify all prerequisites are installed
- Test individual scripts before full release
- File issues on GitHub with complete build logs

The ShelfSpace build system provides a professional, automated workflow for creating high-quality macOS app distributions!
