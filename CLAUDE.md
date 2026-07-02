# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ShelfSpace — a native macOS menu bar clipboard manager (Swift 5.9 / AppKit, no SwiftUI, no external dependencies). Lives in the status bar and shows an NSPopover (420×600) with captured clipboard items (images, text, files). Minimum macOS 13.

## Commands

```bash
make build          # Release build → ShelfSpace.app (runs build.sh)
make run            # Build and open ShelfSpace.app
make watch          # Hot-reload dev mode: debug build, auto-rebuild on Sources/ changes (dev.sh watch)
make clean          # Remove .build/, ShelfSpace.app, dist/
swift build         # Plain debug build (build scripts export DEVELOPER_DIR=/Library/Developer/CommandLineTools)

make dmg            # Build DMG installer into dist/
make release        # Full release pipeline (icons, build, sign, DMG)
make version        # Show version from version.conf
```

There is no test suite and no linter configured. Verify changes by building and running the app.

Version/bundle metadata comes from `version.conf`; `build.sh` generates the Info.plist, so Info.plist changes belong in `build.sh`, not in the app bundle.

## Architecture

Entry flow: `Sources/main.swift` → `AppDelegate` sets up the NSStatusItem, the NSPopover (behavior `.semitransient` to allow drag & drop), `FileShelfViewController` as popover content, and `ClipboardMonitor` (delivers new items via callback → `fileShelfViewController.addItems`).

**FileShelfViewController** (`Sources/Controllers/`) is the hub, split into extensions by concern: `+DataSource` (NSCollectionView data source), `+Delegate` (HeaderView/TabBar/cell delegate conformances), `+ItemActions` (copy/pin/delete/clear), `+DragDrop`. State: `items`, `filteredItems` (derived from `currentFilter: ContentFilter`), `currentViewMode`.

**Cross-cutting communication is NotificationCenter-based.** Singletons post, interested parties observe:
- `SettingsStore.shared` (UserDefaults-backed) posts fine-grained notifications (`settingsPollingIntervalChanged`, `settingsCaptureTypesChanged`, `settingsDidRequestClearAll`, …) declared at the top of `Sources/Settings/SettingsStore.swift`.
- `GridDensityManager.shared` (in `Sources/Layout/AdaptiveGridLayout.swift`) owns view mode (grid/list) and density, persisted in UserDefaults; posts `.viewModeChanged` / `.gridDensityChanged`.

**Layout/cells:** `AdaptiveGridLayout` is a custom NSCollectionViewLayout supporting both grid and list modes. `FileShelfItemCell` (`Sources/Cells/`, split into `+Thumbnails`, `+Interaction`) is a dual-mode cell that switches between grid and list constraint sets by activating/deactivating constraints — don't add a parallel cell class for a new mode.

**Design tokens:** all spacing/typography/corner radii/card sizes live in `DesignSystem.swift`; all colors in `AppColors.swift` (includes legacy aliases, e.g. `primary` → `accent`). Never hardcode colors or spacing in views. The UI matches V0-generated React reference components in `mac-os-clipboard-popover/components/` (header #13131A, card #15151E, hover #1C1C27, accent #8B5CF6).

**Persistence:** `PersistenceManager.shared` saves items to Application Support as JSON; use `saveItemsDebounced` for routine mutations.

**Settings UI:** `SettingsWindowController.shared` with per-pane view controllers in `Sources/Settings/` (all subclassing `SettingsPaneViewController`).

## AppKit pitfalls specific to this codebase

- NSButton has no `titleLabel` (unlike UIKit) — set `title` directly.
- NSCollectionView cells do setup in `loadView()`, not `init`.
- Wrap CALayer property changes in `CATransaction.setDisableActions(true)` to avoid implicit animations.
