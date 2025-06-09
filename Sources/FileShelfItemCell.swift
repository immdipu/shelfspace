import Cocoa

protocol FileShelfItemCellDelegate: AnyObject {
    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestCopyItem item: FileShelfItem)
    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestDeleteItem item: FileShelfItem)
    func fileShelfItemCell(_ cell: FileShelfItemCell, didTogglePinItem item: FileShelfItem)
}

class FileShelfItemCell: NSCollectionViewItem {
    weak var delegate: FileShelfItemCellDelegate?
    
    private let containerView = NSView()
    private let thumbnailImageView = NSImageView()
    private let nameLabel = NSTextField()
    private let sizeLabel = NSTextField()
    private let originLabel = NSTextField()
    private let copyButton = NSButton()
    private let deleteButton = NSButton()
    private let pinButton = NSButton()
    private let overlayView = NSView()
    
    private var fileItem: FileShelfItem?
    
    // Default initializer for collection view registration
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 120, height: 140))
        setupUI()
        setupDragAndDrop()
    }
    
    private func setupUI() {
        view.wantsLayer = true
        
        // Container view with rounded corners
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 10
        containerView.layer?.backgroundColor = AppColors.cardBackground.cgColor
        containerView.layer?.borderWidth = 1
        containerView.layer?.borderColor = AppColors.separator.cgColor
        containerView.layer?.shadowColor = NSColor.black.cgColor
        containerView.layer?.shadowOpacity = 0.1
        containerView.layer?.shadowOffset = NSSize(width: 0, height: 2)
        containerView.layer?.shadowRadius = 4
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Prevent container from expanding
        containerView.setContentHuggingPriority(.required, for: .horizontal)
        containerView.setContentHuggingPriority(.required, for: .vertical)
        containerView.setContentCompressionResistancePriority(.required, for: .horizontal)
        containerView.setContentCompressionResistancePriority(.required, for: .vertical)
        
        view.addSubview(containerView)
        
        // Thumbnail
        thumbnailImageView.imageScaling = .scaleAxesIndependently
        thumbnailImageView.wantsLayer = true
        thumbnailImageView.layer?.cornerRadius = 8
        thumbnailImageView.layer?.masksToBounds = true
        thumbnailImageView.layer?.backgroundColor = AppColors.background.cgColor
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(thumbnailImageView)
        
        // Name label
        nameLabel.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        nameLabel.textColor = AppColors.text
        nameLabel.alignment = .center
        nameLabel.lineBreakMode = .byTruncatingTail
        nameLabel.maximumNumberOfLines = 1
        nameLabel.isEditable = false
        nameLabel.isBordered = false
        nameLabel.backgroundColor = NSColor.clear
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(nameLabel)
        
        // Size label
        sizeLabel.font = NSFont.systemFont(ofSize: 9)
        sizeLabel.textColor = AppColors.secondaryText
        sizeLabel.alignment = .center
        sizeLabel.isEditable = false
        sizeLabel.isBordered = false
        sizeLabel.backgroundColor = NSColor.clear
        sizeLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(sizeLabel)
        
        // Origin label - Keep but will hide it
        originLabel.font = NSFont.systemFont(ofSize: 8)
        originLabel.textColor = AppColors.secondaryText
        originLabel.alignment = .center
        originLabel.isEditable = false
        originLabel.isBordered = false
        originLabel.backgroundColor = NSColor.clear
        originLabel.translatesAutoresizingMaskIntoConstraints = false
        originLabel.isHidden = true
        containerView.addSubview(originLabel)
        
        // Overlay view for action buttons
        overlayView.wantsLayer = true
        overlayView.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.2).cgColor  // More subtle background
        overlayView.layer?.cornerRadius = 8
        overlayView.alphaValue = 0
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(overlayView)
        
        // Action buttons
        setupActionButtons()
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Container - Use explicit size constraints instead of margins
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 116),  // Fixed width
            containerView.heightAnchor.constraint(equalToConstant: 136), // Fixed height
            
            // Thumbnail - fill the entire width with small margins
            thumbnailImageView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 2),
            thumbnailImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 4),
            thumbnailImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -4),
            thumbnailImageView.heightAnchor.constraint(equalToConstant: 95),
            
            // Name label
            nameLabel.topAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor, constant: 1),
            nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            nameLabel.widthAnchor.constraint(equalToConstant: 112),  // Fixed width
            
            // Size label
            sizeLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),  // Reduced from 4 to 2
            sizeLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            sizeLabel.widthAnchor.constraint(equalToConstant: 112),  // Fixed width
            
            // Origin label - Keep constraints but it's hidden
            originLabel.topAnchor.constraint(equalTo: sizeLabel.bottomAnchor, constant: 1),
            originLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            originLabel.widthAnchor.constraint(equalToConstant: 112),  // Fixed width
            
            // Overlay
            overlayView.topAnchor.constraint(equalTo: thumbnailImageView.topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: thumbnailImageView.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: thumbnailImageView.bottomAnchor)
        ])
        
        // Mouse tracking - Don't add here, add after layout is complete
        // let trackingArea = NSTrackingArea(rect: view.bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        // view.addTrackingArea(trackingArea)
    }
    
    private func setupActionButtons() {
        // Copy button
        copyButton.image = NSImage(systemSymbolName: "doc.on.doc", accessibilityDescription: "Copy")
        copyButton.isBordered = false
        copyButton.bezelStyle = .shadowlessSquare
        copyButton.target = self
        copyButton.action = #selector(copyButtonClicked)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(copyButton)
        
        // Pin button
        pinButton.image = NSImage(systemSymbolName: "pin", accessibilityDescription: "Pin")
        pinButton.isBordered = false
        pinButton.bezelStyle = .shadowlessSquare
        pinButton.target = self
        pinButton.action = #selector(pinButtonClicked)
        pinButton.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(pinButton)
        
        // Delete button
        deleteButton.image = NSImage(systemSymbolName: "trash", accessibilityDescription: "Delete")
        deleteButton.isBordered = false
        deleteButton.bezelStyle = .shadowlessSquare
        deleteButton.target = self
        deleteButton.action = #selector(deleteButtonClicked)
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        overlayView.addSubview(deleteButton)
        
        // Style buttons with better appearance - smaller and more subtle
        [copyButton, pinButton, deleteButton].forEach { button in
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor  // Semi-transparent black
            button.layer?.cornerRadius = 10  // Smaller radius for smaller buttons
            button.layer?.borderWidth = 0   // No border for cleaner look
            button.contentTintColor = NSColor.white  // White icons
        }
        
        // Layout action buttons - smaller and better positioned
        NSLayoutConstraint.activate([
            // Copy button - top left
            copyButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 6),
            copyButton.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor, constant: 6),
            copyButton.widthAnchor.constraint(equalToConstant: 20),   // Smaller
            copyButton.heightAnchor.constraint(equalToConstant: 20),  // Smaller
            
            // Pin button - top right
            pinButton.topAnchor.constraint(equalTo: overlayView.topAnchor, constant: 6),
            pinButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -6),
            pinButton.widthAnchor.constraint(equalToConstant: 20),    // Smaller
            pinButton.heightAnchor.constraint(equalToConstant: 20),   // Smaller
            
            // Delete button - bottom right
            deleteButton.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor, constant: -6),
            deleteButton.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor, constant: -6),
            deleteButton.widthAnchor.constraint(equalToConstant: 20),  // Smaller
            deleteButton.heightAnchor.constraint(equalToConstant: 20)  // Smaller
        ])
    }
    
    func configure(with item: FileShelfItem, delegate: FileShelfItemCellDelegate?) {
        // Disable animations during configuration
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0
            context.allowsImplicitAnimation = false
            
            print("=== CELL CONFIGURE DEBUG ===")
            print("Configuring cell with item: \(item.displayName)")
            print("Cell view frame: \(view.frame)")
            print("Container view frame: \(containerView.frame)")
            
            self.fileItem = item
            self.delegate = delegate
            
            // Create a better display name
            let displayName: String
            if item.isImage {
                // For images, use original name if available, otherwise create a timestamp name
                if let fileURL = item.fileURL, !fileURL.lastPathComponent.isEmpty {
                    displayName = fileURL.lastPathComponent
                } else {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM dd, HH:mm"
                    displayName = "Image \(formatter.string(from: item.dateAdded))"
                }
            } else if item.isText {
                // For text, create a short preview or timestamp name
                if let textContent = item.textContent, !textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let preview = String(textContent.prefix(15)).trimmingCharacters(in: .whitespacesAndNewlines)
                    displayName = preview.isEmpty ? "Text Note" : preview
                } else {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "MMM dd, HH:mm"
                    displayName = "Text \(formatter.string(from: item.dateAdded))"
                }
            } else {
                // For other files, use the file name
                displayName = item.displayName
            }
            
            nameLabel.stringValue = displayName
            sizeLabel.stringValue = item.formattedFileSize
            // Don't set origin label since it's hidden
            
            // Update pin button appearance
            let pinImageName = item.isPinned ? "pin.fill" : "pin"
            pinButton.image = NSImage(systemSymbolName: pinImageName, accessibilityDescription: item.isPinned ? "Unpin" : "Pin")
            
            // Load thumbnail
            loadThumbnail(for: item)
            
            // Update container appearance for pinned items
            if item.isPinned {
                containerView.layer?.borderColor = AppColors.primary.cgColor
                containerView.layer?.borderWidth = 2
                containerView.layer?.shadowOpacity = 0.2
            } else {
                containerView.layer?.borderColor = AppColors.separator.cgColor
                containerView.layer?.borderWidth = 1
                containerView.layer?.shadowOpacity = 0.1
            }
            
            // Force layout update
            view.needsLayout = true
            view.layoutSubtreeIfNeeded()
            
            // Add mouse tracking after layout is complete
            setupMouseTracking()
            
            print("After configure - Cell view frame: \(view.frame)")
            print("After configure - Container view frame: \(containerView.frame)")
            print("=== END CELL CONFIGURE DEBUG ===")
        })
    }
    
    private func loadThumbnail(for item: FileShelfItem) {
        if item.isText {
            // Create a text preview image
            if let textContent = item.textContent {
                let textPreview = createTextPreviewImage(text: textContent)
                thumbnailImageView.image = textPreview
            } else {
                // Fallback to text icon
                let icon = NSImage(systemSymbolName: item.itemType.iconName, accessibilityDescription: item.itemType.displayName)!
                icon.size = NSSize(width: 48, height: 48)
                thumbnailImageView.image = icon
            }
        } else if item.isImage, let fileURL = item.fileURL {
            // Load image thumbnail
            DispatchQueue.global(qos: .userInitiated).async {
                if let image = NSImage(contentsOf: fileURL) {
                    let thumbnail = self.createThumbnail(from: image, size: NSSize(width: 80, height: 80))
                    DispatchQueue.main.async {
                        NSAnimationContext.runAnimationGroup({ context in
                            context.duration = 0
                            context.allowsImplicitAnimation = false
                            self.thumbnailImageView.image = thumbnail
                        })
                    }
                }
            }
        } else if let fileURL = item.fileURL {
            // Use file icon or type-specific icon
            let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
            icon.size = NSSize(width: 48, height: 48)
            thumbnailImageView.image = icon
        } else {
            // Fallback icon
            let icon = NSImage(systemSymbolName: item.itemType.iconName, accessibilityDescription: item.itemType.displayName)!
            icon.size = NSSize(width: 48, height: 48)
            thumbnailImageView.image = icon
        }
    }
    
    private func createThumbnail(from image: NSImage, size: NSSize) -> NSImage {
        let thumbnail = NSImage(size: size)
        
        thumbnail.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: size), from: NSRect.zero, operation: .copy, fraction: 1.0)
        thumbnail.unlockFocus()
        
        return thumbnail
    }
    
    private func createTextPreviewImage(text: String) -> NSImage {
        let size = NSSize(width: 80, height: 80)
        let image = NSImage(size: size)
        
        image.lockFocus()
        
        // Background
        AppColors.cardBackground.setFill()
        NSRect(origin: .zero, size: size).fill()
        
        // Text preview
        let truncatedText = String(text.prefix(100)) // Limit to first 100 characters
        let font = NSFont.systemFont(ofSize: 8)
        let textColor = AppColors.text
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]
        
        let textRect = NSRect(x: 4, y: 4, width: size.width - 8, height: size.height - 8)
        truncatedText.draw(in: textRect, withAttributes: attributes)
        
        // Add text icon overlay
        let iconSize: CGFloat = 16
        let iconRect = NSRect(
            x: size.width - iconSize - 4,
            y: size.height - iconSize - 4,
            width: iconSize,
            height: iconSize
        )
        
        if let textIcon = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Text") {
            textIcon.size = NSSize(width: iconSize, height: iconSize)
            textIcon.draw(in: iconRect)
        }
        
        image.unlockFocus()
        
        return image
    }
    
    private func setupDragAndDrop() {
        view.registerForDraggedTypes([.fileURL])
    }
    
    // MARK: - Mouse Events
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        print("🐭 Mouse ENTERED cell")
        // Smooth animation for button reveal
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            overlayView.animator().alphaValue = 1.0
        }
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        print("🐭 Mouse EXITED cell")
        // Smooth animation for button hide
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            overlayView.animator().alphaValue = 0.0
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        print("🐭 Mouse MOVED in cell")
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        print("🐭 Mouse DOWN in cell")
        
        // Check if click is on a button first
        let localPoint = view.convert(event.locationInWindow, from: nil)
        if overlayView.alphaValue > 0 {
            let overlayPoint = overlayView.convert(localPoint, from: view)
            if overlayView.bounds.contains(overlayPoint) {
                // Check each button
                for button in [copyButton, pinButton, deleteButton] {
                    let buttonPoint = button.convert(overlayPoint, from: overlayView)
                    if button.bounds.contains(buttonPoint) {
                        print("🐭 Click on button, not dragging")
                        return // Let button handle the click
                    }
                }
            }
        }
        
        // Start drag operation if not clicking a button
        print("🐭 Starting drag operation")
        guard let item = fileItem, let draggingItem = item.createDraggingItem() else { 
            print("🐭 No drag item created")
            return 
        }
        
        let draggingSession = view.beginDraggingSession(with: [draggingItem], event: event, source: self)
        draggingSession.animatesToStartingPositionsOnCancelOrFail = true
        print("🐭 Drag session started")
    }
    
    // MARK: - Action Methods
    
    @objc private func copyButtonClicked() {
        guard let item = fileItem else { return }
        delegate?.fileShelfItemCell(self, didRequestCopyItem: item)
    }
    
    @objc private func pinButtonClicked() {
        guard let item = fileItem else { return }
        delegate?.fileShelfItemCell(self, didTogglePinItem: item)
        
        // Update pin button immediately
        let pinImageName = item.isPinned ? "pin" : "pin.fill"
        pinButton.image = NSImage(systemSymbolName: pinImageName, accessibilityDescription: item.isPinned ? "Pin" : "Unpin")
    }
    
    @objc private func deleteButtonClicked() {
        guard let item = fileItem else { return }
        delegate?.fileShelfItemCell(self, didRequestDeleteItem: item)
    }
    
    private func setupMouseTracking() {
        // Remove any existing tracking areas
        for trackingArea in view.trackingAreas {
            view.removeTrackingArea(trackingArea)
        }
        
        // Add new tracking area with correct bounds
        let trackingArea = NSTrackingArea(
            rect: view.bounds,
            options: [.mouseEnteredAndExited, .activeInKeyWindow, .mouseMoved],
            owner: self,
            userInfo: nil
        )
        view.addTrackingArea(trackingArea)
        print("Mouse tracking added with bounds: \(view.bounds)")
    }
}

// MARK: - Dragging Source
extension FileShelfItemCell: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
} 