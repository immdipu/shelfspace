# ShelfSpace Makefile Quick Reference

This Makefile simplifies all build, test, and release operations for ShelfSpace.

## 🚀 Quick Start

```bash
# Show all available commands
make help

# Build and run the app
make run

# Create a complete release
make release

# Create a GitHub release
make github-release
```

## 📋 Common Commands

### Development
- `make dev` - Quick development build and run
- `make build` - Build the app bundle  
- `make run` - Build and run the app
- `make clean` - Clean build artifacts
- `make icons` - Generate app icons from icon-1024.png

### Release & Distribution
- `make release` - Create complete release package (DMG + checksums)
- `make dmg` - Create DMG installer only
- `make github-release` - Create GitHub release with current version
- `make tag` - Create and push git tag for current version

### Testing & Validation
- `make validate` - Validate app bundle and check for common issues
- `make test-dmg` - Test DMG by mounting and verifying contents

### Version Management
- `make version` - Show current version info
- `make bump-patch` - Bump patch version (1.0.0 → 1.0.1)
- `make bump-minor` - Bump minor version (1.0.0 → 1.1.0)
- `make bump-major` - Bump major version (1.0.0 → 2.0.0)

### Utilities
- `make info` - Show project information and file sizes
- `make list-files` - List all important project files
- `make setup` - Make all scripts executable

## 🔄 Complete Workflow Examples

### Quick Release
```bash
make quick-release
# Does: clean → build → DMG → GitHub release
```

### Version Bump + Release
```bash
make patch-release   # Bump patch + release
make minor-release   # Bump minor + release
make major-release   # Bump major + release
```

### Custom Workflow
```bash
make clean           # Clean previous builds
make build           # Build the app
make validate        # Check app bundle
make dmg             # Create DMG
make test-dmg        # Test the DMG
make github-release  # Create GitHub release
```

## 💡 Tips

- All commands show colored output with status indicators
- Commands are designed to be safe (won't overwrite without confirmation)
- Use `make help` anytime to see all available commands
- Version bumping automatically updates `version.conf`
- Release commands handle all the complex build steps for you

## 🛠️ Behind the Scenes

The Makefile orchestrates these scripts:
- `build.sh` - Builds the Swift app
- `create-icons.sh` - Generates icon files
- `create-dmg.sh` - Creates DMG installer
- `release.sh` - Complete release pipeline
- `create-release.sh` - GitHub release creation

This makes it much easier to manage the ShelfSpace build and release process!
