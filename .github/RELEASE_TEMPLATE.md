# ShelfSpace Release Template

## ShelfSpace v{VERSION}

A lightweight macOS menu bar application for temporary file and image management.

### 🚀 What's New in v{VERSION}
- Lightweight temporary file and clipboard manager
- Drag & drop files up to 200MB
- Automatic screenshot detection
- Copy/paste text and images
- Smart file categorization
- Pin important items

### 📦 Installation

1. **Download** the `ShelfSpace-{VERSION}.dmg` file from the Assets section below
2. **Open** the DMG file by double-clicking it
3. **Drag** ShelfSpace.app to your Applications folder
4. **Launch** from Applications or Launchpad

### 🔐 First Launch (Important!)

Since this app is not notarized with Apple, you'll need to:

1. **Right-click** on ShelfSpace.app in Applications
2. **Select "Open"** from the context menu
3. **Click "Open"** in the security dialog
4. **Grant permissions** when prompted (for clipboard access and file management)

### 📋 System Requirements

- **macOS 13.0** (Ventura) or later
- **Intel** or **Apple Silicon** Mac
- **~5MB** of disk space

### 🛡️ File Verification

For security, you can verify the download integrity:

```bash
# Download both the DMG and .sha256 files, then run:
shasum -a 256 -c ShelfSpace-{VERSION}.dmg.sha256
```

### 🎯 Key Features

- **Menu Bar Integration**: Lives discreetly in your macOS menu bar
- **Drag & Drop Support**: Accept files from Finder, browsers, and other apps
- **Clipboard Monitoring**: Automatically captures screenshots and copied images
- **Copy & Reuse**: One-click copy back to clipboard for sites that block drag & drop
- **Thumbnail Display**: Beautiful previews of images and file icons
- **Smart Storage**: Maintains last 50 items with automatic cleanup
- **Pin Important Items**: Keep important files with pinning feature

### 🆘 Support

- **Issues**: Report bugs at [GitHub Issues](https://github.com/immdipu/shelfspace/issues)
- **Feature Requests**: Submit ideas in [GitHub Discussions](https://github.com/immdipu/shelfspace/discussions)
- **Documentation**: Full docs in the [README](https://github.com/immdipu/shelfspace#readme)

### 📄 Release Assets

- `ShelfSpace-{VERSION}.dmg` - Main application installer
- `ShelfSpace-{VERSION}.dmg.sha256` - Security checksum
- `RELEASE_INFO.txt` - Detailed release information

---

**Note**: This is an unsigned application. If you encounter security warnings, follow the "First Launch" instructions above.
