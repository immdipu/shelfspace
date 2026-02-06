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
        listActionsContainer.alphaValue = 0
        gridContainer.layer?.backgroundColor = AppColors.cardBackground.cgColor
        listContainer.layer?.backgroundColor = NSColor.clear.cgColor

        CATransaction.commit()

        // Setup tracking
        setupMouseTracking()
    }

    private func setupPreviewContent(for item: FileShelfItem) {
        // Hide all preview types first
        thumbnailImageView.isHidden = true
        textPreviewLabel.isHidden = true
        fileIconContainer.isHidden = true
        fileSizeInPreview.isHidden = true

        if item.isText {
            if let content = item.textContent {
                textPreviewLabel.stringValue = String(content.prefix(120))
                textPreviewLabel.isHidden = false
            }
        } else if item.isImage {
            thumbnailImageView.isHidden = false
            loadGridThumbnail(for: item)
        } else {
            // File type: show icon + size in preview
            fileIconContainer.isHidden = false
            fileSizeInPreview.isHidden = false
            fileSizeInPreview.stringValue = item.formattedFileSize
            if let icon = NSImage(systemSymbolName: item.itemType.iconName, accessibilityDescription: nil) {
                let config = NSImage.SymbolConfiguration(pointSize: 20, weight: .regular)
                fileIconView.image = icon.withSymbolConfiguration(config)
            }
        }
    }

    private func setupListIcon(for item: FileShelfItem) {
        listIconView.isHidden = false
        listIconImageView.isHidden = true

        if item.isImage, let fileURL = item.fileURL {
            // Show actual image thumbnail in list icon
            listIconView.isHidden = true
            listIconImageView.isHidden = false
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                var image = NSImage(contentsOf: fileURL)
                if image == nil, let data = try? Data(contentsOf: fileURL) {
                    image = NSImage(data: data)
                }
                if let loadedImage = image {
                    DispatchQueue.main.async {
                        self?.listIconImageView.image = loadedImage
                    }
                }
            }
        }
    }

    private func loadGridThumbnail(for item: FileShelfItem) {
        guard let fileURL = item.fileURL else { return }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            // Try loading from file URL
            var image: NSImage?

            // First try direct load
            image = NSImage(contentsOf: fileURL)

            // Fallback: try loading from file data
            if image == nil, let data = try? Data(contentsOf: fileURL) {
                image = NSImage(data: data)
            }

            if let loadedImage = image {
                DispatchQueue.main.async {
                    self?.thumbnailImageView.image = loadedImage
                    self?.thumbnailImageView.imageScaling = .scaleProportionallyUpOrDown
                }
            }
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
        isHovering = true

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            ctx.allowsImplicitAnimation = true

            if currentViewMode == .grid {
                // Grid hover: change bg, show overlay with smooth fade
                gridContainer.layer?.backgroundColor = AppColors.cardHover.cgColor
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
                // List hover: change bg, fade in actions
                listContainer.layer?.backgroundColor = AppColors.listHover.cgColor
                listActionsContainer.animator().alphaValue = 1
                listPinIndicator.isHidden = true
            }
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHovering = false

        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            ctx.allowsImplicitAnimation = true

            if currentViewMode == .grid {
                gridContainer.layer?.backgroundColor = AppColors.cardBackground.cgColor
                hoverOverlay.animator().alphaValue = 0
                gridContainer.layer?.masksToBounds = true
                gridContainer.layer?.shadowOpacity = 0

                if fileItem?.isPinned == true {
                    pinBadge.isHidden = false
                    gridContainer.layer?.borderColor = AppColors.accentPinnedBorder.cgColor
                } else {
                    gridContainer.layer?.borderColor = AppColors.whiteOverlay4.cgColor
                }
            } else {
                listContainer.layer?.backgroundColor = NSColor.clear.cgColor
                listActionsContainer.animator().alphaValue = 0
                if fileItem?.isPinned == true {
                    listPinIndicator.isHidden = false
                }
            }
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
