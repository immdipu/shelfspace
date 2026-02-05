# ShelfSpace Makefile
# Simplifies building, testing, and releasing the ShelfSpace macOS app

# Default target
.DEFAULT_GOAL := help

# Colors for output
BLUE := \033[34m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

# Paths
BUILD_DIR := .build
DIST_DIR := dist

##
## Development
##

.PHONY: dev
dev: ## Quick development build and run
	@echo "$(BLUE)🛠️  Building for development...$(RESET)"
	./dev.sh

.PHONY: build
build: ## Build the app bundle
	@echo "$(BLUE)🔨 Building ShelfSpace...$(RESET)"
	./build.sh
	@echo "$(GREEN)✅ Build complete: ShelfSpace.app$(RESET)"

.PHONY: icons
icons: ## Generate app icons from icon-1024.png
	@echo "$(BLUE)🎨 Generating app icons...$(RESET)"
	./create-icons.sh
	@echo "$(GREEN)✅ Icons generated$(RESET)"

.PHONY: run
run: build ## Build and run the app
	@echo "$(BLUE)🚀 Launching ShelfSpace...$(RESET)"
	open ShelfSpace.app

.PHONY: watch
watch: ## Hot reload development mode (auto-rebuild on file changes)
	@echo "$(BLUE)🔥 Starting hot reload development mode...$(RESET)"
	./dev.sh watch

.PHONY: dev
dev: watch ## Alias for watch (hot reload development mode)

.PHONY: clean
clean: ## Clean build artifacts
	@echo "$(YELLOW)🧹 Cleaning build artifacts...$(RESET)"
	rm -rf $(BUILD_DIR)
	rm -rf ShelfSpace.app
	rm -rf $(DIST_DIR)
	@echo "$(GREEN)✅ Clean complete$(RESET)"

##
## Release & Distribution
##

.PHONY: release
release: ## Create complete release package (DMG + checksums)
	@echo "$(BLUE)📦 Creating complete release package...$(RESET)"
	./release.sh
	@echo "$(GREEN)✅ Release package created in dist/$(RESET)"

.PHONY: dmg
dmg: build ## Create DMG installer only
	@echo "$(BLUE)💿 Creating DMG installer...$(RESET)"
	./create-dmg.sh
	@echo "$(GREEN)✅ DMG created in dist/$(RESET)"

.PHONY: github-release
github-release: release ## Create GitHub release with current version
	@echo "$(BLUE)🚀 Creating GitHub release...$(RESET)"
	./create-release.sh

.PHONY: tag
tag: ## Create and push git tag for current version
	@echo "$(BLUE)🏷️  Creating git tag...$(RESET)"
	@source version.conf && git tag -a "v$$APP_VERSION" -m "ShelfSpace v$$APP_VERSION"
	@source version.conf && git push origin "v$$APP_VERSION"
	@source version.conf && echo "$(GREEN)✅ Tag v$$APP_VERSION created and pushed$(RESET)"

##
## Testing & Validation
##

.PHONY: test-dmg
test-dmg: dmg ## Test DMG by mounting and verifying contents
	@echo "$(BLUE)🧪 Testing DMG...$(RESET)"
	@source version.conf && DMG_FILE="dist/$$APP_NAME-$$APP_VERSION.dmg"; \
	if [ -f "$$DMG_FILE" ]; then \
		echo "Mounting DMG..."; \
		MOUNT_POINT=$$(hdiutil attach "$$DMG_FILE" | grep "/Volumes/" | cut -d$$'\t' -f3); \
		if [ -d "$$MOUNT_POINT/ShelfSpace.app" ]; then \
			echo "$(GREEN)✅ DMG test passed$(RESET)"; \
		else \
			echo "$(RED)❌ DMG test failed$(RESET)"; \
		fi; \
		hdiutil detach "$$MOUNT_POINT" > /dev/null 2>&1; \
	else \
		echo "$(RED)❌ DMG file not found$(RESET)"; \
		exit 1; \
	fi

.PHONY: validate
validate: ## Validate app bundle and check for common issues
	@echo "$(BLUE)🔍 Validating app bundle...$(RESET)"
	@if [ -d "ShelfSpace.app" ]; then \
		echo "Checking executable..."; \
		if [ -x "ShelfSpace.app/Contents/MacOS/ShelfSpace" ]; then \
			echo "$(GREEN)✅ Executable found and is executable$(RESET)"; \
		else \
			echo "$(RED)❌ Executable missing or not executable$(RESET)"; \
		fi; \
		echo "Checking Info.plist..."; \
		if [ -f "ShelfSpace.app/Contents/Info.plist" ]; then \
			plutil -lint "ShelfSpace.app/Contents/Info.plist" > /dev/null 2>&1 && \
			echo "$(GREEN)✅ Info.plist is valid$(RESET)" || \
			echo "$(RED)❌ Info.plist is invalid$(RESET)"; \
		else \
			echo "$(RED)❌ Info.plist missing$(RESET)"; \
		fi; \
		echo "Checking icon..."; \
		if [ -f "ShelfSpace.app/Contents/Resources/ShelfSpace.icns" ]; then \
			echo "$(GREEN)✅ App icon found$(RESET)"; \
		else \
			echo "$(YELLOW)⚠️  App icon missing$(RESET)"; \
		fi; \
		APP_SIZE=$$(du -sh "ShelfSpace.app" | cut -f1); \
		echo "$(BLUE)📦 App bundle size: $$APP_SIZE$(RESET)"; \
	else \
		echo "$(RED)❌ App bundle not found. Run 'make build' first.$(RESET)"; \
		exit 1; \
	fi

##
## Version Management
##

.PHONY: version
version: ## Show current version
	@source version.conf && echo "$(BLUE)📋 Current version: $$APP_VERSION$(RESET)"
	@source version.conf && echo "$(BLUE)📱 App name: $$APP_NAME$(RESET)"
	@source version.conf && echo "$(BLUE)🆔 Bundle ID: $$BUNDLE_ID$(RESET)"

.PHONY: bump-patch
bump-patch: ## Bump patch version (1.0.0 -> 1.0.1)
	@echo "$(BLUE)⬆️  Bumping patch version...$(RESET)"
	@source version.conf && current=$$(echo $$APP_VERSION | cut -d. -f1-2); \
	patch=$$(echo $$APP_VERSION | cut -d. -f3); \
	new_patch=$$((patch + 1)); \
	new_version="$$current.$$new_patch"; \
	sed -i '' "s/APP_VERSION=\"$$APP_VERSION\"/APP_VERSION=\"$$new_version\"/" version.conf; \
	echo "$(GREEN)✅ Version bumped: $$APP_VERSION → $$new_version$(RESET)"

.PHONY: bump-minor
bump-minor: ## Bump minor version (1.0.0 -> 1.1.0)
	@echo "$(BLUE)⬆️  Bumping minor version...$(RESET)"
	@source version.conf && major=$$(echo $$APP_VERSION | cut -d. -f1); \
	minor=$$(echo $$APP_VERSION | cut -d. -f2); \
	new_minor=$$((minor + 1)); \
	new_version="$$major.$$new_minor.0"; \
	sed -i '' "s/APP_VERSION=\"$$APP_VERSION\"/APP_VERSION=\"$$new_version\"/" version.conf; \
	echo "$(GREEN)✅ Version bumped: $$APP_VERSION → $$new_version$(RESET)"

.PHONY: bump-major
bump-major: ## Bump major version (1.0.0 -> 2.0.0)
	@echo "$(BLUE)⬆️  Bumping major version...$(RESET)"
	@source version.conf && major=$$(echo $$APP_VERSION | cut -d. -f1); \
	new_major=$$((major + 1)); \
	new_version="$$new_major.0.0"; \
	sed -i '' "s/APP_VERSION=\"$$APP_VERSION\"/APP_VERSION=\"$$new_version\"/" version.conf; \
	echo "$(GREEN)✅ Version bumped: $$APP_VERSION → $$new_version$(RESET)"

##
## Utilities
##

.PHONY: info
info: ## Show project information and file sizes
	@echo "$(BLUE)📊 ShelfSpace Project Information$(RESET)"
	@echo "=================================="
	@source version.conf && echo "$(BLUE)Version:$(RESET) $$APP_VERSION"
	@source version.conf && echo "$(BLUE)App Name:$(RESET) $$APP_NAME"
	@source version.conf && echo "$(BLUE)Bundle ID:$(RESET) $$BUNDLE_ID"
	@source version.conf && echo "$(BLUE)Developer:$(RESET) $$DEVELOPER_NAME"
	@source version.conf && echo "$(BLUE)Min macOS:$(RESET) $$MIN_MACOS_VERSION"
	@echo ""
	@if [ -d "ShelfSpace.app" ]; then \
		echo "$(BLUE)App Bundle:$(RESET) $$(du -sh ShelfSpace.app | cut -f1)"; \
	fi
	@source version.conf && if [ -f "dist/$$APP_NAME-$$APP_VERSION.dmg" ]; then \
		echo "$(BLUE)DMG Size:$(RESET) $$(du -sh dist/$$APP_NAME-$$APP_VERSION.dmg | cut -f1)"; \
	fi
	@if [ -f "icon-1024.png" ]; then \
		echo "$(BLUE)Source Icon:$(RESET) $$(du -sh icon-1024.png | cut -f1)"; \
	fi

.PHONY: list-files
list-files: ## List all important project files
	@echo "$(BLUE)📁 Project Files$(RESET)"
	@echo "================"
	@echo "$(YELLOW)Source Files:$(RESET)"
	@find Sources -name "*.swift" | sed 's/^/  /'
	@echo ""
	@echo "$(YELLOW)Build Scripts:$(RESET)"
	@ls -1 *.sh | sed 's/^/  /'
	@echo ""
	@echo "$(YELLOW)Configuration:$(RESET)"
	@ls -1 *.conf *.entitlements Makefile 2>/dev/null | sed 's/^/  /' || true
	@echo ""
	@if [ -d "$(DIST_DIR)" ]; then \
		echo "$(YELLOW)Distribution Files:$(RESET)"; \
		ls -1 $(DIST_DIR)/ | sed 's/^/  /'; \
	fi

.PHONY: setup
setup: ## Initial project setup (make scripts executable)
	@echo "$(BLUE)⚙️  Setting up project...$(RESET)"
	chmod +x *.sh
	@echo "$(GREEN)✅ All scripts are now executable$(RESET)"

.PHONY: help
help: ## Show this help message
	@awk 'BEGIN {FS = ":.*##"; printf "$(BLUE)ShelfSpace Makefile$(RESET)\n\nUsage:\n  make $(YELLOW)<target>$(RESET)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(YELLOW)%-15s$(RESET) %s\n", $$1, $$2 } /^##/ { printf "\n$(BLUE)%s$(RESET)\n", substr($$0, 3) } ' $(MAKEFILE_LIST)

##
## Full Workflow Examples
##

.PHONY: quick-release
quick-release: clean release github-release ## Complete release workflow: clean → build → DMG → GitHub release
	@echo "$(GREEN)🎉 Complete release workflow finished!$(RESET)"
	@echo "$(BLUE)🔗 Check your release at: https://github.com/immdipu/shelfspace/releases$(RESET)"

.PHONY: patch-release
patch-release: bump-patch quick-release ## Bump patch version and create full release
	@echo "$(GREEN)🎉 Patch release completed!$(RESET)"

.PHONY: minor-release
minor-release: bump-minor quick-release ## Bump minor version and create full release
	@echo "$(GREEN)🎉 Minor release completed!$(RESET)"

.PHONY: major-release
major-release: bump-major quick-release ## Bump major version and create full release
	@echo "$(GREEN)🎉 Major release completed!$(RESET)"
