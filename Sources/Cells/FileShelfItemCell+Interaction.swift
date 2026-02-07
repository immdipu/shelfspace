import Cocoa

// MARK: - Configuration & Mouse Events

extension FileShelfItemCell {
    func configure(with item: FileShelfItem, delegate: FileShelfItemCellDelegate?) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        self.fileItem = item
        self.delegate = delegate

        let displayName = Self.makeDisplayName(for: item)
        let typeIconName = item.itemType.iconName

        // Set type icon for both modes
        if let typeIcon = NSImage(systemSymbolName: typeIconName, accessibilityDescription: item.itemType.displayName) {
            let config12 = NSImage.SymbolConfiguration(pointSize: 12, weight: .regular)
            let config16 = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            gridTypeIcon.image = typeIcon.withSymbolConfiguration(config12)
            listIconView.image = typeIcon.withSymbolConfiguration(config16)
        }

        // Grid mode data
        gridNameLabel.stringValue = displayName
        gridSizeLabel.stringValue = item.formattedFileSize

        // Apply dynamic density settings
        updateForDensity()

        // Apply dynamic appearance settings
        let cornerRadius = CGFloat(SettingsStore.shared.cardCornerRadius)
        gridContainer.layer?.cornerRadius = cornerRadius
        gridSizeLabel.isHidden = !SettingsStore.shared.showFileSizeInGrid

        // List mode data
        listNameLabel.stringValue = displayName

        // List subtitle varies by type
        if item.isText, let content = item.textContent {
            listSubtitleLabel.stringValue = content.components(separatedBy: .newlines).first ?? ""
        } else {
            listSubtitleLabel.stringValue = item.formattedFileSize
        }

        // Setup preview area content based on type
        setupPreviewContent(for: item)

        // Setup list icon based on type
        setupListIcon(for: item)

        // Pin state
        let pinImageName = item.isPinned ? "pin.fill" : "pin"
        gridPinButton.updateIcon(symbolName: pinImageName)
        gridPinButton.setActionActive(item.isPinned)
        listPinButton.updateIcon(symbolName: pinImageName)
        listPinButton.setActionActive(item.isPinned)
        pinBadge.isHidden = !item.isPinned
        listPinIndicator.isHidden = !item.isPinned
        listPinnedBorder.isHidden = !item.isPinned

        if item.isPinned {
            gridContainer.layer?.borderColor = AppColors.accentPinnedBorder.cgColor
        } else {
            gridContainer.layer?.borderColor = AppColors.whiteOverlay4.cgColor
        }

        // Reset hover state
        isHovering = false
        hoverOverlay.alphaValue = 0
        hoverOverlay.isHidden = true
        listActionsContainer.alphaValue = 0
        gridContainer.layer?.backgroundColor = AppColors.cardBackground.cgColor
        listContainer.layer?.backgroundColor = NSColor.clear.cgColor

        CATransaction.commit()

        // Setup tracking
        setupMouseTracking()
    }

    /// Updates cell layout for the current density (compact/comfortable/large)
    func updateForDensity() {
        let density = GridDensityManager.shared.currentDensity

        // Update preview and footer height constraints
        previewHeightConstraint?.constant = density.previewHeight
        footerHeightConstraint?.constant = density.footerHeight

        // Adapt fonts based on density
        switch density {
        case .compact:
            gridNameLabel.font = NSFont.systemFont(ofSize: 10, weight: .medium)
            gridSizeLabel.font = NSFont.systemFont(ofSize: 8, weight: .regular)
        case .comfortable:
            gridNameLabel.font = DesignSystem.Typography.body
            gridSizeLabel.font = DesignSystem.Typography.small
        case .large:
            gridNameLabel.font = DesignSystem.Typography.subtitle
            gridSizeLabel.font = DesignSystem.Typography.body
        }
    }

    private func setupPreviewContent(for item: FileShelfItem) {
        // Hide everything — we ONLY use thumbnailImageView for all preview types
        thumbnailImageView.isHidden = true
        textPreviewLabel.isHidden = true
        fileIconContainer.isHidden = true
        fileSizeInPreview.isHidden = true
        previewTypeIcon.isHidden = true
        previewTypeIcon.image = nil
        thumbnailImageView.image = nil
        thumbnailImageView.layer?.contents = nil

        // Reset thumbnail style to contain for non-image types
        thumbnailImageView.imageScaling = .scaleProportionallyUpOrDown
        thumbnailImageView.imageAlignment = .alignCenter

        let trimmedText = item.textContent?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        if !trimmedText.isEmpty {
            // TEXT ITEMS: Render text as an image and show via thumbnailImageView
            let textImage = createTextPreviewImage(text: trimmedText)
            thumbnailImageView.image = textImage
            thumbnailImageView.imageScaling = .scaleAxesIndependently  // Fill the preview area
            thumbnailImageView.isHidden = false
        } else if item.isImage {
            // IMAGE ITEMS: Load actual image thumbnail
            thumbnailImageView.isHidden = false
            loadGridThumbnail(for: item)
        } else if let fileURL = item.fileURL, isTextFile(fileURL: fileURL, mimeType: item.mimeType) {
            // TEXT FILES (dropped .txt/.md/.swift etc): Load text from file, render as image
            thumbnailImageView.isHidden = false
            // Show placeholder first
            let placeholderImage = createTextPreviewImage(text: "Loading…")
            thumbnailImageView.image = placeholderImage
            thumbnailImageView.imageScaling = .scaleAxesIndependently

            let token = UUID()
            textLoadToken = token
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe)
                let text = data.flatMap {
                    String(data: $0, encoding: .utf8)
                        ?? String(data: $0, encoding: .utf16)
                        ?? String(data: $0, encoding: .ascii)
                }
                let snippet = text.map { String($0.prefix(2000)) } ?? "Could not read file"
                DispatchQueue.main.async {
                    guard let self = self,
                          self.textLoadToken == token,
                          self.fileItem?.id == item.id else { return }
                    let textImage = self.createTextPreviewImage(text: snippet)
                    self.thumbnailImageView.image = textImage
                    self.thumbnailImageView.imageScaling = .scaleAxesIndependently
                    self.thumbnailImageView.isHidden = false
                }
            }
        } else {
            // FILE ITEMS: Render icon + size as an image
            let iconImage = createFileIconPreviewImage(
                iconName: item.itemType.iconName,
                fileSize: item.formattedFileSize
            )
            thumbnailImageView.image = iconImage
            thumbnailImageView.imageScaling = .scaleAxesIndependently
            thumbnailImageView.isHidden = false
        }
    }

    private func isTextFile(fileURL: URL, mimeType: String) -> Bool {
        if mimeType.lowercased().hasPrefix("text/") { return true }
        let ext = fileURL.pathExtension.lowercased()
        let textExtensions: Set<String> = [
            "txt", "md", "markdown", "rtf", "json", "xml", "csv", "tsv",
            "yaml", "yml", "log", "ini", "conf", "cfg", "toml",
            "html", "css", "js", "ts", "swift", "py", "rb", "java", "kt",
            "c", "cc", "cpp", "h", "hpp", "m", "mm", "sh", "zsh", "bash"
        ]
        return textExtensions.contains(ext)
    }

    /// Applies the loaded image with the current thumbnail style (contain or cover)
    private func applyImage(_ image: NSImage) {
        let style = GridDensityManager.shared.currentThumbnailStyle
        thumbnailImageView.wantsLayer = true
        previewArea.layer?.masksToBounds = true

        switch style {
        case .contain:
            thumbnailImageView.layer?.contents = nil
            thumbnailImageView.imageScaling = .scaleProportionallyUpOrDown
            thumbnailImageView.imageAlignment = .alignCenter
            thumbnailImageView.image = image
        case .cover:
            // Use layer-based rendering for true aspect-fill (cover)
            thumbnailImageView.image = nil
            thumbnailImageView.imageScaling = .scaleNone
            if let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
                thumbnailImageView.layer?.contentsGravity = .resizeAspectFill
                thumbnailImageView.layer?.contents = cgImage
            }
        }
    }

    private func setupListIcon(for item: FileShelfItem) {
        listIconView.isHidden = false
        listIconImageView.isHidden = true
        listIconImageView.image = nil

        if item.isImage, let fileURL = item.fileURL {
            let token = UUID()
            listIconLoadToken = token
            loadImage(from: fileURL) { [weak self] image in
                guard let self = self,
                      self.listIconLoadToken == token,
                      self.fileItem?.id == item.id else { return }

                if let loadedImage = image {
                    self.listIconImageView.image = loadedImage
                    self.listIconImageView.isHidden = false
                    self.listIconView.isHidden = true
                } else {
                    self.listIconImageView.isHidden = true
                    self.listIconView.isHidden = false
                }
            }
        }
    }

    private func loadGridThumbnail(for item: FileShelfItem) {
        guard let fileURL = item.fileURL else {
            showImageFallback(for: item)
            return
        }

        let token = UUID()
        thumbnailLoadToken = token
        loadImage(from: fileURL) { [weak self] image in
            guard let self = self,
                  self.thumbnailLoadToken == token,
                  self.fileItem?.id == item.id else { return }

            if let loadedImage = image {
                self.applyImage(loadedImage)
                self.thumbnailImageView.isHidden = false
                self.fileIconContainer.isHidden = true
                self.fileSizeInPreview.isHidden = true
            } else {
                self.thumbnailImageView.image = nil
                self.thumbnailImageView.layer?.contents = nil
                self.thumbnailImageView.isHidden = true
                self.showImageFallback(for: item)
            }
        }
    }

    private func loadImage(from fileURL: URL, completion: @escaping (NSImage?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let data = try? Data(contentsOf: fileURL)
            DispatchQueue.main.async {
                if let data = data, let image = NSImage(data: data) {
                    completion(image)
                } else {
                    completion(NSImage(contentsOf: fileURL))
                }
            }
        }
    }

    private func showImageFallback(for item: FileShelfItem) {
        fileIconContainer.isHidden = false
        fileSizeInPreview.isHidden = false
        fileSizeInPreview.stringValue = item.formattedFileSize
        if let icon = NSImage(systemSymbolName: item.itemType.iconName, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 20, weight: .regular)
            fileIconView.image = icon.withSymbolConfiguration(config)
        }
    }

    static func makeDisplayName(for item: FileShelfItem) -> String {
        if item.isImage {
            if let fileURL = item.fileURL, !fileURL.lastPathComponent.isEmpty {
                return fileURL.lastPathComponent
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, HH:mm"
            return "Image \(formatter.string(from: item.dateAdded))"
        } else if item.isText {
            if let content = item.textContent, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                let preview = String(content.prefix(15)).trimmingCharacters(in: .whitespacesAndNewlines)
                return preview.isEmpty ? "Text Note" : preview
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, HH:mm"
            return "Text \(formatter.string(from: item.dateAdded))"
        }
        return item.displayName
    }

    // MARK: - Mouse Events

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        applyHoverState(true)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        if isMouseInsideCard() { return }
        applyHoverState(false)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        let inside = isPointInsideCard(event.locationInWindow)
        if inside != isHovering {
            applyHoverState(inside)
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        // Check if click is on an action button
        let localPoint = view.convert(event.locationInWindow, from: nil)

        if currentViewMode == .grid {
            let overlayPoint = hoverOverlay.convert(localPoint, from: view)
            for button in [gridCopyButton, gridPinButton, gridDeleteButton] {
                let buttonPoint = button.convert(overlayPoint, from: hoverOverlay)
                if button.bounds.contains(buttonPoint) { return }
            }
        } else {
            let containerPoint = listActionsContainer.convert(localPoint, from: view)
            for button in [listCopyButton, listPinButton, listDeleteButton] {
                let buttonPoint = button.convert(containerPoint, from: listActionsContainer)
                if button.bounds.contains(buttonPoint) { return }
            }
        }

        // Start drag if not clicking a button
        guard let item = fileItem, let draggingItem = item.createDraggingItem() else { return }
        let session = view.beginDraggingSession(with: [draggingItem], event: event, source: self)
        session.animatesToStartingPositionsOnCancelOrFail = true
    }

    private func applyHoverState(_ hovering: Bool) {
        guard hovering != isHovering else { return }
        isHovering = hovering

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = hovering ? 0.2 : 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: hovering ? .easeOut : .easeIn)
            ctx.allowsImplicitAnimation = true

            if currentViewMode == .grid {
                if hovering {
                    // Grid hover: change bg, show overlay with smooth fade
                    gridContainer.layer?.backgroundColor = AppColors.cardHover.cgColor
                    hoverOverlay.isHidden = false
                    hoverOverlay.animator().alphaValue = 1
                    pinBadge.isHidden = true

                    // Subtle lift with shadow
                    if let layer = gridContainer.layer {
                        layer.masksToBounds = false
                        layer.shadowColor = NSColor.black.cgColor
                        layer.shadowOpacity = 0.3
                        layer.shadowRadius = 12
                        layer.shadowOffset = CGSize(width: 0, height: -4)
                    }

                    // Border glow
                    if !(fileItem?.isPinned ?? false) {
                        gridContainer.layer?.borderColor = AppColors.whiteOverlay6.cgColor
                    }
                } else {
                    gridContainer.layer?.backgroundColor = AppColors.cardBackground.cgColor
                    hoverOverlay.animator().alphaValue = 0
                    hoverOverlay.isHidden = true
                    gridContainer.layer?.masksToBounds = true
                    gridContainer.layer?.shadowOpacity = 0

                    if fileItem?.isPinned == true {
                        pinBadge.isHidden = false
                        gridContainer.layer?.borderColor = AppColors.accentPinnedBorder.cgColor
                    } else {
                        gridContainer.layer?.borderColor = AppColors.whiteOverlay4.cgColor
                    }
                }
            } else {
                if hovering {
                    // List hover: change bg, fade in actions
                    listContainer.layer?.backgroundColor = AppColors.listHover.cgColor
                    listActionsContainer.animator().alphaValue = 1
                    listPinIndicator.isHidden = true
                } else {
                    listContainer.layer?.backgroundColor = NSColor.clear.cgColor
                    listActionsContainer.animator().alphaValue = 0
                    if fileItem?.isPinned == true {
                        listPinIndicator.isHidden = false
                    }
                }
            }
        }
    }

    private func isPointInsideCard(_ locationInWindow: NSPoint) -> Bool {
        let localPoint = view.convert(locationInWindow, from: nil)
        let targetFrame = currentViewMode == .grid ? gridContainer.frame : listContainer.frame
        return targetFrame.contains(localPoint)
    }

    private func isMouseInsideCard() -> Bool {
        guard let window = view.window else { return false }
        return isPointInsideCard(window.mouseLocationOutsideOfEventStream)
    }

    func setupMouseTracking() {
        for area in view.trackingAreas {
            view.removeTrackingArea(area)
        }
        // Use .activeAlways since popover windows may not be key
        let area = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect, .mouseMoved],
            owner: self, userInfo: nil
        )
        view.addTrackingArea(area)
    }
}
