# ShelfSpace

A native macOS menu bar clipboard manager built with Swift. Capture images, text, and files automatically — organized, searchable, always one click away.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-8B5CF6)
![Swift](https://img.shields.io/badge/Swift-5.9-F05138)
![License](https://img.shields.io/badge/License-MIT-22C55E)

## Features

**Clipboard Monitoring** — Auto-captures copied images, text, and files with smart content detection, duplicate filtering, and configurable polling interval.

**Drag & Drop** — Drop files directly into the app (up to 200MB) or drag items out to any other application.

**Grid & List Views** — Switch between grid and list layouts with three density levels: compact, comfortable, and large.

**Content Filtering** — Five tabs (All, Pinned, Images, Text, Files) with live item counts and instant switching.

**Pin Important Items** — Pin items to protect them from auto-cleanup. Persisted across app restarts with visual indicators.

**Rich Previews** — Image thumbnails, text content rendering, syntax-highlighted code previews, and file type icons with size display.

**Quick Actions** — Hover-activated copy, pin, and delete buttons with animated feedback.

**Persistent Storage** — Items saved automatically to Application Support. Survives app restarts with debounced auto-save.

**Customizable Settings** — Polling interval, file size limits, text length limits, capture type toggles, density, thumbnail style (contain/cover), corner radius, and auto-clear retention.

**Native Performance** — Built with Swift and AppKit. Minimal memory footprint with smart background processing.

**Launch at Login** — Start automatically with macOS. Configure menu bar and Dock visibility.

**Bulk Management** — Clear all items, clear only unpinned, or set auto-clear retention by days.

## Installation

### Download (Recommended)

1. Download **ShelfSpace.dmg** from the [latest release](https://github.com/immdipu/shelfspace/releases/latest)
2. Open the DMG and drag ShelfSpace to Applications
3. Launch from Applications
4. **First launch**: If macOS shows a warning, right-click the app and select **"Open"**, then click "Open" in the dialog. This is only needed once — macOS remembers your choice after that.
5. If you see "damaged and can't be opened", run this in Terminal and then open the app:
   ```bash
   xattr -cr /Applications/ShelfSpace.app
   ```

### Build from Source

```bash
git clone https://github.com/immdipu/shelfspace.git
cd shelfspace
make run
```

Or step by step:

```bash
make icons    # Generate app icon from icon-1024.png
make build    # Build ShelfSpace.app
make release  # Full pipeline: icons + build + DMG + checksums
```

Run `make help` to see all available commands.

## Usage

1. **Launch** — ShelfSpace appears as a menu bar icon
2. **Click** the icon to open the clipboard shelf
3. **Copy** anything — images, text, files are captured automatically
4. **Drop** files directly into the panel
5. **Filter** by type using the tab bar (All, Pinned, Images, Text, Files)
6. **Hover** over items for quick actions (copy, pin, delete)
7. **Drag** items out of ShelfSpace into any app
8. **Pin** important items to keep them safe from cleanup

## Project Structure

```
Sources/
├── AppDelegate.swift              # Menu bar setup and app lifecycle
├── Cells/                         # FileShelfItemCell (grid + list modes)
├── Controllers/                   # FileShelfViewController + extensions
├── Layout/                        # AdaptiveGridLayout (grid/list/density)
├── Models/                        # FileShelfItem, ContentFilter
├── Persistence/                   # PersistenceManager (auto-save)
├── Protocols/                     # FileShelfItemCellDelegate
├── Services/                      # ClipboardMonitor
├── Settings/                      # Settings window (6 panes)
├── Utilities/                     # Logger, AnimationHelper, TempDirectoryManager
└── Views/                         # HeaderView, TabBar, ToolbarView, EmptyStateView
```

## Configuration

All settings are accessible from the gear icon in the app header:

| Category | Settings |
|---|---|
| **General** | Show in menu bar, show in Dock, launch at login |
| **Clipboard** | Enable/disable monitoring, polling interval, max file size, max text length |
| **Capture** | Toggle file/image/text capture independently, ignore duplicates |
| **Storage** | Max items (up to 1000), auto-clear retention days |
| **Appearance** | Thumbnail style (contain/cover), show file size, corner radius |
| **About** | Version info, GitHub link, report issues |

## Tech Stack

- **Swift 5.9** + **AppKit** — Native macOS, no SwiftUI or Electron
- **Core Animation** — Smooth animations and visual effects
- **Swift Package Manager** — Build system
- **NSPopover** — 420x580px panel from the menu bar

## Privacy

- All data stored locally on your Mac (`~/Library/Application Support/ShelfSpace/`)
- No network requests, no analytics, no telemetry
- Temporary files cleaned up automatically

## Version Management

```bash
make version       # Show current version
make bump-patch    # 1.0.0 → 1.0.1
make bump-minor    # 1.0.0 → 1.1.0
make bump-major    # 1.0.0 → 2.0.0
make github-release  # Tag + push + create GitHub release with DMG
```

## Contributing

Contributions welcome. Fork the repo, create a feature branch, and submit a pull request.

## License

MIT

---

Built by [Dipu](https://github.com/immdipu)
