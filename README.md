# FileShelf 📁

A lightweight macOS menu bar application that acts as a temporary file and image shelf, inspired by apps like Dropover. FileShelf provides a minimal, clean experience for managing temporary files, images, and screenshots.

![FileShelf Demo](https://img.shields.io/badge/Platform-macOS%2013%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 🔹 Core Features

- **Menu Bar Integration**: Lives discreetly in your macOS menu bar
- **Drag & Drop Support**: Accept files from Finder, browsers, and other apps
- **Clipboard Monitoring**: Automatically captures screenshots and copied images
- **Copy & Reuse**: One-click copy back to clipboard for sites that block drag & drop
- **Drag Back Out**: Drag stored files to other applications
- **Thumbnail Display**: Beautiful previews of images and file icons
- **Temporary Storage**: Smart storage with automatic cleanup
- **Pin Important Items**: Keep important files with pinning feature

### 🔸 Smart Features

- **Screenshot Detection**: Automatically identifies and stores screenshots
- **File Type Recognition**: Proper MIME type detection and icons
- **Storage Limits**: Maintains last 50 items (pinned items exempt)
- **Unique File Handling**: Prevents conflicts with duplicate filenames
- **Native macOS Integration**: Uses SF Symbols and system colors

### 🎨 User Interface

- **Clean & Minimal**: Designed for daily productivity workflows
- **Dark/Light Mode**: Automatic adaptation to system appearance
- **Hover Actions**: Copy, pin, and delete buttons on hover
- **Visual Feedback**: Smooth animations and state indicators
- **Responsive Layout**: Adapts to different content types

## 🚀 Quick Start

### Prerequisites

- macOS 13.0 (Ventura) or later
- Xcode Command Line Tools
- Swift 5.9+

### Building from Source

1. **Clone the repository**:

   ```bash
   git clone <repository-url>
   cd macapp
   ```

2. **Make the build script executable**:

   ```bash
   chmod +x build.sh
   ```

3. **Build the application**:

   ```bash
   ./build.sh
   ```

4. **Run the app**:

   ```bash
   open FileShelf.app
   ```

5. **Install to Applications** (optional):
   ```bash
   cp -r FileShelf.app /Applications/
   ```

### Development Setup

For development in VS Code:

1. **Open in VS Code**:

   ```bash
   code .
   ```

2. **Install Swift extension** for VS Code
3. **Build and test**:
   ```bash
   swift build
   swift run
   ```

## 🎯 How to Use

### Getting Started

1. Launch FileShelf - it will appear in your menu bar as a tray icon
2. Click the menu bar icon to open the file shelf panel
3. Start dropping files or copying images to populate your shelf

### Adding Files

- **Drag & Drop**: Drag files from Finder, browsers, or other apps into the drop zone
- **Clipboard Monitoring**: Copy images or take screenshots - they'll automatically appear
- **Multiple Sources**: Support for web images, local files, and screenshots

### Managing Items

- **Copy**: Click the copy button to copy items back to clipboard
- **Pin**: Click the pin button to keep important items permanently
- **Delete**: Click the trash button to remove individual items
- **Clear All**: Use the "Clear All" button to remove all unpinned items
- **Drag Out**: Drag items from the shelf to other applications

### File Operations

- **Thumbnails**: Automatic thumbnail generation for images
- **File Info**: Display file name, size, and origin (Screenshot/Copied/Dropped)
- **Smart Storage**: Temporary files stored in system temp directory
- **Cleanup**: Automatic cleanup when items are removed or app quits

## 🏗️ Architecture

### Project Structure

```
Sources/
├── main.swift                  # Application entry point
├── AppDelegate.swift           # Menu bar setup and lifecycle
├── FileShelfViewController.swift # Main UI controller
├── FileShelfItem.swift         # Data model for stored files
├── FileShelfItemCell.swift     # Collection view cell for items
├── DropZoneView.swift          # Drag & drop interface
└── ClipboardMonitor.swift      # Clipboard monitoring service
```

### Key Components

- **AppDelegate**: Manages menu bar item and application lifecycle
- **FileShelfViewController**: Main UI with collection view and drop zone
- **ClipboardMonitor**: Background service for clipboard watching
- **FileShelfItem**: Data model with file operations and metadata
- **DropZoneView**: Custom view with drag & drop visual feedback
- **FileShelfItemCell**: Individual item display with hover actions

### Technology Stack

- **Swift 5.9**: Modern Swift with latest features
- **AppKit**: Native macOS UI framework
- **Core Animation**: Smooth animations and visual effects
- **Foundation**: File operations and system integration
- **UniformTypeIdentifiers**: MIME type detection

## 🔧 Configuration

### Storage Behavior

- **Temporary Storage**: Files stored in `~/Library/Caches/FileShelf/`
- **Max Items**: 50 items (configurable in source)
- **Pinned Items**: Exempt from automatic cleanup
- **File Cleanup**: Automatic cleanup on app termination

### Customization Options

- Modify `maxItems` in `FileShelfViewController` to change storage limit
- Adjust polling interval in `ClipboardMonitor` for clipboard checking
- Customize UI colors and animations in respective view files

## 🛠️ Development

### Building for Distribution

1. **Create release build**:

   ```bash
   swift build -c release
   ```

2. **Code signing** (for distribution):

   ```bash
   codesign --force --deep --sign "Developer ID Application: Your Name" FileShelf.app
   ```

3. **Create DMG** (optional):
   ```bash
   hdiutil create -volname "FileShelf" -srcfolder FileShelf.app -ov -format UDZO FileShelf.dmg
   ```

### Testing

- **Manual Testing**: Build and run the app to test all features
- **File Types**: Test with various file types (images, documents, etc.)
- **Drag & Drop**: Test drag operations from different sources
- **Clipboard**: Test screenshot and image copying scenarios

## 🎨 UI/UX Design

### Design Principles

- **Minimal & Clean**: Focused on productivity without clutter
- **Native Feel**: Uses macOS design patterns and components
- **Discoverable**: Clear visual cues for all interactions
- **Responsive**: Immediate feedback for all user actions

### Visual Elements

- **SF Symbols**: System icons for consistency
- **System Colors**: Automatic dark/light mode support
- **Rounded Corners**: Modern macOS aesthetic
- **Subtle Animations**: Enhance usability without distraction

## 🔒 Privacy & Security

- **Local Storage**: All files stored locally on your Mac
- **No Network**: No data transmitted over the network
- **Temporary Files**: Automatic cleanup of temporary storage
- **System Integration**: Uses standard macOS APIs and patterns

## 🐛 Troubleshooting

### Common Issues

**App doesn't appear in menu bar**:

- Check if app is running: `ps aux | grep FileShelf`
- Try restarting the app
- Check macOS permissions for accessibility

**Clipboard monitoring not working**:

- Grant accessibility permissions in System Preferences
- Check if other clipboard managers are interfering

**Drag & drop not working**:

- Ensure source application supports file dragging
- Try dragging to the drop zone area specifically

**Build errors**:

- Ensure Xcode Command Line Tools are installed: `xcode-select --install`
- Check Swift version: `swift --version`
- Clean build: `rm -rf .build`

## 📝 License

MIT License - feel free to modify and distribute.

## 🤝 Contributing

Contributions welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**FileShelf** - Making file management effortless on macOS 🚀
