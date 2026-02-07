import Cocoa

class FileShelfItemCell: NSCollectionViewItem {
    weak var delegate: FileShelfItemCellDelegate?

    // MARK: - Shared State

    var fileItem: FileShelfItem?
    var isHovering = false
    var currentViewMode: DesignSystem.ViewMode = .list
    var thumbnailLoadToken = UUID()
    var listIconLoadToken = UUID()

    // MARK: - Grid Mode Views

    let gridContainer = NSView()
    let previewArea = NSView()
    let thumbnailImageView = NSImageView()
    let textPreviewLabel = NSTextField()
    let fileIconContainer = NSView()
    let fileIconView = NSImageView()
    let fileSizeInPreview = NSTextField()
    let gradientLayer = CAGradientLayer()
    let hoverOverlay = HoverOverlayView()
    let gridCopyButton = GridActionButton(symbolName: "doc.on.doc", label: "Copy")
    let gridPinButton = GridActionButton(symbolName: "pin", label: "Pin")
    let gridDeleteButton = GridActionButton(symbolName: "trash", label: "Delete", isDanger: true)
    let pinBadge = NSView()
    let pinBadgeIcon = NSImageView()
    let gridFooter = NSView()
    let gridTypeIconContainer = NSView()
    let gridTypeIcon = NSImageView()
    let gridNameLabel = NSTextField()
    let gridSizeLabel = NSTextField()

    // MARK: - List Mode Views

    let listContainer = NSView()
    let listIconContainer = NSView()
    let listIconView = NSImageView()
    let listIconImageView = NSImageView()
    let listNameLabel = NSTextField()
    let listSubtitleLabel = NSTextField()
    let listActionsContainer = NSView()
    let listCopyButton = ListActionButton(symbolName: "doc.on.doc", label: "Copy")
    let listPinButton = ListActionButton(symbolName: "pin", label: "Pin")
    let listDeleteButton = ListActionButton(symbolName: "trash", label: "Delete", isDanger: true)
    let listPinIndicator = NSImageView()
    let listPinnedBorder = NSView()

    // MARK: - Constraint Sets

    private var gridConstraints: [NSLayoutConstraint] = []
    private var listConstraints: [NSLayoutConstraint] = []

    // MARK: - Initialization

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        setupGridViews()
        setupListViews()
        setupConstraints()
        setupDragAndDrop()
        // Activate the correct constraint set now that they're populated
        applyViewMode(currentViewMode)
    }

    // MARK: - Grid Setup

    private func setupGridViews() {
        // Grid container: rounded-xl, bg #15151E
        gridContainer.wantsLayer = true
        gridContainer.layer?.cornerRadius = DesignSystem.GridCard.cornerRadius
        gridContainer.layer?.backgroundColor = AppColors.cardBackground.cgColor
        gridContainer.layer?.borderWidth = 1
        gridContainer.layer?.borderColor = AppColors.whiteOverlay4.cgColor
        gridContainer.layer?.masksToBounds = true
        gridContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(gridContainer)

        // Preview area: 100px height, bg #111119
        previewArea.wantsLayer = true
        previewArea.layer?.backgroundColor = AppColors.previewBackground.cgColor
        previewArea.translatesAutoresizingMaskIntoConstraints = false
        gridContainer.addSubview(previewArea)

        // Thumbnail for images
        thumbnailImageView.imageScaling = .scaleProportionallyUpOrDown
        thumbnailImageView.imageAlignment = .alignCenter
        thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbnailImageView.isHidden = true
        previewArea.addSubview(thumbnailImageView)

        // Text preview for text items
        textPreviewLabel.font = DesignSystem.Typography.mono
        textPreviewLabel.textColor = AppColors.previewText
        textPreviewLabel.isEditable = false
        textPreviewLabel.isBordered = false
        textPreviewLabel.drawsBackground = false
        textPreviewLabel.maximumNumberOfLines = 6
        textPreviewLabel.lineBreakMode = .byTruncatingTail
        textPreviewLabel.translatesAutoresizingMaskIntoConstraints = false
        textPreviewLabel.isHidden = true
        previewArea.addSubview(textPreviewLabel)

        // File icon for file items (centered icon in preview)
        fileIconContainer.wantsLayer = true
        fileIconContainer.layer?.backgroundColor = AppColors.accentIconBg.cgColor
        fileIconContainer.layer?.cornerRadius = 8
        fileIconContainer.translatesAutoresizingMaskIntoConstraints = false
        fileIconContainer.isHidden = true
        previewArea.addSubview(fileIconContainer)

        fileIconView.contentTintColor = AppColors.accent
        fileIconView.imageScaling = .scaleProportionallyUpOrDown
        fileIconView.translatesAutoresizingMaskIntoConstraints = false
        fileIconContainer.addSubview(fileIconView)

        fileSizeInPreview.font = DesignSystem.Typography.small
        fileSizeInPreview.textColor = AppColors.textDim
        fileSizeInPreview.alignment = .center
        fileSizeInPreview.isEditable = false
        fileSizeInPreview.isBordered = false
        fileSizeInPreview.drawsBackground = false
        fileSizeInPreview.translatesAutoresizingMaskIntoConstraints = false
        fileSizeInPreview.isHidden = true
        previewArea.addSubview(fileSizeInPreview)

        // Gradient fade at bottom of preview
        gradientLayer.colors = [NSColor.clear.cgColor, AppColors.cardBackground.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        previewArea.layer?.addSublayer(gradientLayer)

        // Hover overlay with blur
        hoverOverlay.wantsLayer = true
        hoverOverlay.layer?.backgroundColor = AppColors.hoverOverlay.cgColor
        hoverOverlay.alphaValue = 0
        hoverOverlay.translatesAutoresizingMaskIntoConstraints = false
        previewArea.addSubview(hoverOverlay)

        // Grid action buttons inside hover overlay
        for button in [gridCopyButton, gridPinButton, gridDeleteButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            hoverOverlay.addSubview(button)
        }
        gridCopyButton.target = self
        gridCopyButton.action = #selector(copyClicked)
        gridPinButton.target = self
        gridPinButton.action = #selector(pinClicked)
        gridDeleteButton.target = self
        gridDeleteButton.action = #selector(deleteClicked)

        // Pin badge (top-right, only visible when pinned and not hovered)
        pinBadge.wantsLayer = true
        pinBadge.layer?.backgroundColor = AppColors.accentBorder.cgColor
        pinBadge.layer?.cornerRadius = 10
        pinBadge.isHidden = true
        pinBadge.translatesAutoresizingMaskIntoConstraints = false
        previewArea.addSubview(pinBadge)

        if let pinIcon = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: "Pinned") {
            let config = NSImage.SymbolConfiguration(pointSize: 10, weight: .regular)
            pinBadgeIcon.image = pinIcon.withSymbolConfiguration(config)
        }
        pinBadgeIcon.contentTintColor = AppColors.accent
        pinBadgeIcon.translatesAutoresizingMaskIntoConstraints = false
        pinBadge.addSubview(pinBadgeIcon)

        // Footer: type icon + name + size
        gridFooter.translatesAutoresizingMaskIntoConstraints = false
        gridContainer.addSubview(gridFooter)

        gridTypeIconContainer.wantsLayer = true
        gridTypeIconContainer.layer?.backgroundColor = AppColors.accentIconBg.cgColor
        gridTypeIconContainer.layer?.cornerRadius = DesignSystem.CornerRadius.sm
        gridTypeIconContainer.translatesAutoresizingMaskIntoConstraints = false
        gridFooter.addSubview(gridTypeIconContainer)

        gridTypeIcon.contentTintColor = AppColors.accent
        gridTypeIcon.imageScaling = .scaleProportionallyUpOrDown
        gridTypeIcon.translatesAutoresizingMaskIntoConstraints = false
        gridTypeIconContainer.addSubview(gridTypeIcon)

        gridNameLabel.font = DesignSystem.Typography.body
        gridNameLabel.textColor = AppColors.textPrimary
        gridNameLabel.lineBreakMode = .byTruncatingTail
        gridNameLabel.maximumNumberOfLines = 1
        gridNameLabel.cell?.lineBreakMode = .byTruncatingTail
        gridNameLabel.cell?.truncatesLastVisibleLine = true
        gridNameLabel.isEditable = false
        gridNameLabel.isBordered = false
        gridNameLabel.drawsBackground = false
        gridNameLabel.translatesAutoresizingMaskIntoConstraints = false
        gridFooter.addSubview(gridNameLabel)

        gridSizeLabel.font = DesignSystem.Typography.small
        gridSizeLabel.textColor = AppColors.textDim
        gridSizeLabel.lineBreakMode = .byTruncatingTail
        gridSizeLabel.maximumNumberOfLines = 1
        gridSizeLabel.isEditable = false
        gridSizeLabel.isBordered = false
        gridSizeLabel.drawsBackground = false
        gridSizeLabel.translatesAutoresizingMaskIntoConstraints = false
        gridFooter.addSubview(gridSizeLabel)
    }

    // MARK: - List Setup

    private func setupListViews() {
        // List container: transparent bg, hover #1A1A24
        listContainer.wantsLayer = true
        listContainer.layer?.backgroundColor = NSColor.clear.cgColor
        listContainer.layer?.cornerRadius = 8
        listContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(listContainer)

        // Pinned left border
        listPinnedBorder.wantsLayer = true
        listPinnedBorder.layer?.backgroundColor = AppColors.accent.cgColor
        listPinnedBorder.isHidden = true
        listPinnedBorder.translatesAutoresizingMaskIntoConstraints = false
        listContainer.addSubview(listPinnedBorder)

        // Type icon: 36x36 rounded-md bg #1E1E28
        listIconContainer.wantsLayer = true
        listIconContainer.layer?.backgroundColor = AppColors.backgroundTertiary.cgColor
        listIconContainer.layer?.cornerRadius = DesignSystem.ListCard.iconCornerRadius
        listIconContainer.layer?.masksToBounds = true
        listIconContainer.translatesAutoresizingMaskIntoConstraints = false
        listContainer.addSubview(listIconContainer)

        listIconView.contentTintColor = AppColors.accent
        listIconView.imageScaling = .scaleProportionallyUpOrDown
        listIconView.translatesAutoresizingMaskIntoConstraints = false
        listIconContainer.addSubview(listIconView)

        listIconImageView.imageScaling = .scaleProportionallyUpOrDown
        listIconImageView.imageAlignment = .alignCenter
        listIconImageView.translatesAutoresizingMaskIntoConstraints = false
        listIconImageView.isHidden = true
        listIconContainer.addSubview(listIconImageView)

        // Name label: 13px medium #EBEBEF
        listNameLabel.font = DesignSystem.Typography.subtitle
        listNameLabel.textColor = AppColors.textPrimary
        listNameLabel.lineBreakMode = .byTruncatingTail
        listNameLabel.maximumNumberOfLines = 1
        listNameLabel.cell?.lineBreakMode = .byTruncatingTail
        listNameLabel.cell?.truncatesLastVisibleLine = true
        listNameLabel.isEditable = false
        listNameLabel.isBordered = false
        listNameLabel.drawsBackground = false
        listNameLabel.translatesAutoresizingMaskIntoConstraints = false
        listContainer.addSubview(listNameLabel)

        // Subtitle: 11px mono #71717A
        listSubtitleLabel.font = DesignSystem.Typography.monoSmall
        listSubtitleLabel.textColor = AppColors.textTertiary
        listSubtitleLabel.lineBreakMode = .byTruncatingTail
        listSubtitleLabel.maximumNumberOfLines = 1
        listSubtitleLabel.isEditable = false
        listSubtitleLabel.isBordered = false
        listSubtitleLabel.drawsBackground = false
        listSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        listContainer.addSubview(listSubtitleLabel)

        // Action buttons container (only visible on hover)
        listActionsContainer.translatesAutoresizingMaskIntoConstraints = false
        listActionsContainer.alphaValue = 0
        listContainer.addSubview(listActionsContainer)

        for button in [listCopyButton, listPinButton, listDeleteButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            listActionsContainer.addSubview(button)
        }
        listCopyButton.target = self
        listCopyButton.action = #selector(copyClicked)
        listPinButton.target = self
        listPinButton.action = #selector(pinClicked)
        listDeleteButton.target = self
        listDeleteButton.action = #selector(deleteClicked)

        // Pin indicator (only visible when pinned and NOT hovered)
        if let pinIcon = NSImage(systemSymbolName: "pin.fill", accessibilityDescription: "Pinned") {
            let config = NSImage.SymbolConfiguration(pointSize: 12, weight: .regular)
            listPinIndicator.image = pinIcon.withSymbolConfiguration(config)
        }
        listPinIndicator.contentTintColor = AppColors.accent
        listPinIndicator.isHidden = true
        listPinIndicator.translatesAutoresizingMaskIntoConstraints = false
        listContainer.addSubview(listPinIndicator)
    }

    // MARK: - Constraints

    private func setupConstraints() {
        // Grid constraints
        gridConstraints = [
            gridContainer.topAnchor.constraint(equalTo: view.topAnchor),
            gridContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gridContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gridContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Preview area
            previewArea.topAnchor.constraint(equalTo: gridContainer.topAnchor),
            previewArea.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor),
            previewArea.trailingAnchor.constraint(equalTo: gridContainer.trailingAnchor),
            previewArea.heightAnchor.constraint(equalToConstant: DesignSystem.GridCard.previewHeight),

            // Thumbnail fills preview
            thumbnailImageView.topAnchor.constraint(equalTo: previewArea.topAnchor),
            thumbnailImageView.leadingAnchor.constraint(equalTo: previewArea.leadingAnchor),
            thumbnailImageView.trailingAnchor.constraint(equalTo: previewArea.trailingAnchor),
            thumbnailImageView.bottomAnchor.constraint(equalTo: previewArea.bottomAnchor),

            // Text preview
            textPreviewLabel.topAnchor.constraint(equalTo: previewArea.topAnchor, constant: 10),
            textPreviewLabel.leadingAnchor.constraint(equalTo: previewArea.leadingAnchor, constant: 12),
            textPreviewLabel.trailingAnchor.constraint(equalTo: previewArea.trailingAnchor, constant: -12),
            textPreviewLabel.bottomAnchor.constraint(lessThanOrEqualTo: previewArea.bottomAnchor, constant: -4),

            // File icon in preview
            fileIconContainer.centerXAnchor.constraint(equalTo: previewArea.centerXAnchor),
            fileIconContainer.centerYAnchor.constraint(equalTo: previewArea.centerYAnchor, constant: -8),
            fileIconContainer.widthAnchor.constraint(equalToConstant: 40),
            fileIconContainer.heightAnchor.constraint(equalToConstant: 40),
            fileIconView.centerXAnchor.constraint(equalTo: fileIconContainer.centerXAnchor),
            fileIconView.centerYAnchor.constraint(equalTo: fileIconContainer.centerYAnchor),
            fileIconView.widthAnchor.constraint(equalToConstant: 20),
            fileIconView.heightAnchor.constraint(equalToConstant: 20),
            fileSizeInPreview.centerXAnchor.constraint(equalTo: previewArea.centerXAnchor),
            fileSizeInPreview.topAnchor.constraint(equalTo: fileIconContainer.bottomAnchor, constant: 8),

            // Hover overlay fills preview
            hoverOverlay.topAnchor.constraint(equalTo: previewArea.topAnchor),
            hoverOverlay.leadingAnchor.constraint(equalTo: previewArea.leadingAnchor),
            hoverOverlay.trailingAnchor.constraint(equalTo: previewArea.trailingAnchor),
            hoverOverlay.bottomAnchor.constraint(equalTo: previewArea.bottomAnchor),

            // Grid action buttons centered in overlay, gap-2 (8px)
            gridPinButton.centerXAnchor.constraint(equalTo: hoverOverlay.centerXAnchor),
            gridPinButton.centerYAnchor.constraint(equalTo: hoverOverlay.centerYAnchor),
            gridPinButton.widthAnchor.constraint(equalToConstant: DesignSystem.ActionButton.gridSize),
            gridPinButton.heightAnchor.constraint(equalToConstant: DesignSystem.ActionButton.gridSize),
            gridCopyButton.trailingAnchor.constraint(equalTo: gridPinButton.leadingAnchor, constant: -8),
            gridCopyButton.centerYAnchor.constraint(equalTo: hoverOverlay.centerYAnchor),
            gridCopyButton.widthAnchor.constraint(equalToConstant: DesignSystem.ActionButton.gridSize),
            gridCopyButton.heightAnchor.constraint(equalToConstant: DesignSystem.ActionButton.gridSize),
            gridDeleteButton.leadingAnchor.constraint(equalTo: gridPinButton.trailingAnchor, constant: 8),
            gridDeleteButton.centerYAnchor.constraint(equalTo: hoverOverlay.centerYAnchor),
            gridDeleteButton.widthAnchor.constraint(equalToConstant: DesignSystem.ActionButton.gridSize),
            gridDeleteButton.heightAnchor.constraint(equalToConstant: DesignSystem.ActionButton.gridSize),

            // Pin badge: top-right, 20x20
            pinBadge.topAnchor.constraint(equalTo: previewArea.topAnchor, constant: 8),
            pinBadge.trailingAnchor.constraint(equalTo: previewArea.trailingAnchor, constant: -8),
            pinBadge.widthAnchor.constraint(equalToConstant: 20),
            pinBadge.heightAnchor.constraint(equalToConstant: 20),
            pinBadgeIcon.centerXAnchor.constraint(equalTo: pinBadge.centerXAnchor),
            pinBadgeIcon.centerYAnchor.constraint(equalTo: pinBadge.centerYAnchor),

            // Footer
            gridFooter.topAnchor.constraint(equalTo: previewArea.bottomAnchor),
            gridFooter.leadingAnchor.constraint(equalTo: gridContainer.leadingAnchor),
            gridFooter.trailingAnchor.constraint(equalTo: gridContainer.trailingAnchor),
            gridFooter.bottomAnchor.constraint(equalTo: gridContainer.bottomAnchor),

            // Type icon in footer: 24x24
            gridTypeIconContainer.leadingAnchor.constraint(equalTo: gridFooter.leadingAnchor, constant: 12),
            gridTypeIconContainer.centerYAnchor.constraint(equalTo: gridFooter.centerYAnchor),
            gridTypeIconContainer.widthAnchor.constraint(equalToConstant: 24),
            gridTypeIconContainer.heightAnchor.constraint(equalToConstant: 24),
            gridTypeIcon.centerXAnchor.constraint(equalTo: gridTypeIconContainer.centerXAnchor),
            gridTypeIcon.centerYAnchor.constraint(equalTo: gridTypeIconContainer.centerYAnchor),
            gridTypeIcon.widthAnchor.constraint(equalToConstant: 12),
            gridTypeIcon.heightAnchor.constraint(equalToConstant: 12),

            // Name and size in footer
            gridNameLabel.leadingAnchor.constraint(equalTo: gridTypeIconContainer.trailingAnchor, constant: 8),
            gridNameLabel.trailingAnchor.constraint(equalTo: gridFooter.trailingAnchor, constant: -12),
            gridNameLabel.topAnchor.constraint(equalTo: gridFooter.topAnchor, constant: 8),

            gridSizeLabel.leadingAnchor.constraint(equalTo: gridTypeIconContainer.trailingAnchor, constant: 8),
            gridSizeLabel.trailingAnchor.constraint(equalTo: gridFooter.trailingAnchor, constant: -12),
            gridSizeLabel.topAnchor.constraint(equalTo: gridNameLabel.bottomAnchor, constant: 1),
        ]

        // List constraints
        listConstraints = [
            listContainer.topAnchor.constraint(equalTo: view.topAnchor),
            listContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Pinned border: 2px left
            listPinnedBorder.leadingAnchor.constraint(equalTo: listContainer.leadingAnchor),
            listPinnedBorder.topAnchor.constraint(equalTo: listContainer.topAnchor),
            listPinnedBorder.bottomAnchor.constraint(equalTo: listContainer.bottomAnchor),
            listPinnedBorder.widthAnchor.constraint(equalToConstant: 2),

            // Icon: 36x36, leading 12, centered
            listIconContainer.leadingAnchor.constraint(equalTo: listContainer.leadingAnchor, constant: 12),
            listIconContainer.centerYAnchor.constraint(equalTo: listContainer.centerYAnchor),
            listIconContainer.widthAnchor.constraint(equalToConstant: 36),
            listIconContainer.heightAnchor.constraint(equalToConstant: 36),
            listIconView.centerXAnchor.constraint(equalTo: listIconContainer.centerXAnchor),
            listIconView.centerYAnchor.constraint(equalTo: listIconContainer.centerYAnchor),
            listIconView.widthAnchor.constraint(equalToConstant: 16),
            listIconView.heightAnchor.constraint(equalToConstant: 16),
            listIconImageView.topAnchor.constraint(equalTo: listIconContainer.topAnchor),
            listIconImageView.leadingAnchor.constraint(equalTo: listIconContainer.leadingAnchor),
            listIconImageView.trailingAnchor.constraint(equalTo: listIconContainer.trailingAnchor),
            listIconImageView.bottomAnchor.constraint(equalTo: listIconContainer.bottomAnchor),

            // Name: gap-3 (12px) from icon
            listNameLabel.leadingAnchor.constraint(equalTo: listIconContainer.trailingAnchor, constant: 12),
            listNameLabel.topAnchor.constraint(equalTo: listContainer.topAnchor, constant: 8),
            listNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: listActionsContainer.leadingAnchor, constant: -8),

            // Subtitle
            listSubtitleLabel.leadingAnchor.constraint(equalTo: listIconContainer.trailingAnchor, constant: 12),
            listSubtitleLabel.topAnchor.constraint(equalTo: listNameLabel.bottomAnchor, constant: 2),
            listSubtitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: listActionsContainer.leadingAnchor, constant: -8),

            // Actions container (right side)
            listActionsContainer.trailingAnchor.constraint(equalTo: listContainer.trailingAnchor, constant: -12),
            listActionsContainer.centerYAnchor.constraint(equalTo: listContainer.centerYAnchor),
            listActionsContainer.heightAnchor.constraint(equalToConstant: 28),

            // List action buttons: 28x28
            listCopyButton.leadingAnchor.constraint(equalTo: listActionsContainer.leadingAnchor),
            listCopyButton.centerYAnchor.constraint(equalTo: listActionsContainer.centerYAnchor),
            listCopyButton.widthAnchor.constraint(equalToConstant: 28),
            listCopyButton.heightAnchor.constraint(equalToConstant: 28),
            listPinButton.leadingAnchor.constraint(equalTo: listCopyButton.trailingAnchor, constant: 4),
            listPinButton.centerYAnchor.constraint(equalTo: listActionsContainer.centerYAnchor),
            listPinButton.widthAnchor.constraint(equalToConstant: 28),
            listPinButton.heightAnchor.constraint(equalToConstant: 28),
            listDeleteButton.leadingAnchor.constraint(equalTo: listPinButton.trailingAnchor, constant: 4),
            listDeleteButton.centerYAnchor.constraint(equalTo: listActionsContainer.centerYAnchor),
            listDeleteButton.widthAnchor.constraint(equalToConstant: 28),
            listDeleteButton.heightAnchor.constraint(equalToConstant: 28),
            listDeleteButton.trailingAnchor.constraint(equalTo: listActionsContainer.trailingAnchor),

            // Pin indicator (right side, visible when pinned + not hovered)
            listPinIndicator.trailingAnchor.constraint(equalTo: listContainer.trailingAnchor, constant: -12),
            listPinIndicator.centerYAnchor.constraint(equalTo: listContainer.centerYAnchor),
            listPinIndicator.widthAnchor.constraint(equalToConstant: 14),
            listPinIndicator.heightAnchor.constraint(equalToConstant: 14),
        ]
    }

    func applyViewMode(_ mode: DesignSystem.ViewMode) {
        currentViewMode = mode

        if mode == .grid {
            NSLayoutConstraint.deactivate(listConstraints)
            listContainer.isHidden = true
            gridContainer.isHidden = false
            NSLayoutConstraint.activate(gridConstraints)
        } else {
            NSLayoutConstraint.deactivate(gridConstraints)
            gridContainer.isHidden = true
            listContainer.isHidden = false
            NSLayoutConstraint.activate(listConstraints)
        }
    }

    override func viewDidLayout() {
        super.viewDidLayout()
        // Update gradient layer frame
        let gradientHeight: CGFloat = 24
        gradientLayer.frame = CGRect(
            x: 0,
            y: previewArea.bounds.height - gradientHeight,
            width: previewArea.bounds.width,
            height: gradientHeight
        )
    }

    // MARK: - Actions

    @objc func copyClicked() {
        guard let item = fileItem else { return }
        delegate?.fileShelfItemCell(self, didRequestCopyItem: item)
    }

    @objc func pinClicked() {
        guard let item = fileItem else { return }
        delegate?.fileShelfItemCell(self, didTogglePinItem: item)
        updatePinState()
    }

    @objc func deleteClicked() {
        guard let item = fileItem else { return }
        delegate?.fileShelfItemCell(self, didRequestDeleteItem: item)
    }

    private func updatePinState() {
        guard let item = fileItem else { return }
        let pinImageName = item.isPinned ? "pin.fill" : "pin"

        // Grid pin button
        gridPinButton.updateIcon(symbolName: pinImageName)
        gridPinButton.setActionActive(item.isPinned)

        // List pin button
        listPinButton.updateIcon(symbolName: pinImageName)
        listPinButton.setActionActive(item.isPinned)

        // Pin badge (grid)
        pinBadge.isHidden = !item.isPinned || isHovering

        // Pin indicator (list)
        listPinIndicator.isHidden = !item.isPinned || isHovering

        // Pinned border (list)
        listPinnedBorder.isHidden = !item.isPinned

        // Grid pinned border
        if item.isPinned {
            gridContainer.layer?.borderColor = AppColors.accentPinnedBorder.cgColor
        } else {
            gridContainer.layer?.borderColor = AppColors.whiteOverlay4.cgColor
        }
    }

    private func setupDragAndDrop() {
        view.registerForDraggedTypes([.fileURL])
    }

    // Legacy compatibility
    let nameLabel = NSTextField()
    let sizeLabel = NSTextField()
    let actionBar = NSView()
    let copyButton = NSButton()
    let pinButton = NSButton()
    let deleteButton = NSButton()
    let pinnedIndicator = NSView()
    let containerView = NSView()

    func updateActionBarAppearance(hovered: Bool) {}
    func updatePinnedAppearance(isPinned: Bool) {}
}

// MARK: - Dragging Source

extension FileShelfItemCell: NSDraggingSource {
    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
}

// MARK: - Hover Overlay (passes through mouse events when transparent)

class HoverOverlayView: NSView {
    override func hitTest(_ point: NSPoint) -> NSView? {
        // Only intercept clicks when overlay is visible
        if alphaValue < 0.1 { return nil }
        return super.hitTest(point)
    }
}

// MARK: - Grid Action Button (32x32, rounded-lg)

class GridActionButton: NSButton {
    private var trackingArea: NSTrackingArea?
    private var isButtonHovered = false
    private var isDanger = false
    private var isActionActive = false

    init(symbolName: String, label: String, isDanger: Bool = false) {
        self.isDanger = isDanger
        super.init(frame: .zero)
        if let img = NSImage(systemSymbolName: symbolName, accessibilityDescription: label) {
            let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .regular)
            self.image = img.withSymbolConfiguration(config)
        }
        setupButton()
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupButton() {
        isBordered = false
        bezelStyle = .shadowlessSquare
        imagePosition = .imageOnly
        wantsLayer = true
        layer?.cornerRadius = DesignSystem.ActionButton.gridCornerRadius
        layer?.backgroundColor = AppColors.whiteOverlay8.cgColor
        layer?.borderWidth = 1
        layer?.borderColor = AppColors.whiteOverlay6.cgColor
        layer?.masksToBounds = true
        contentTintColor = AppColors.textLight
        focusRingType = .none
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func updateIcon(symbolName: String) {
        if let img = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .regular)
            self.image = img.withSymbolConfiguration(config)
        }
    }

    override var intrinsicContentSize: NSSize {
        return NSSize(width: DesignSystem.ActionButton.gridSize, height: DesignSystem.ActionButton.gridSize)
    }

    override var alignmentRectInsets: NSEdgeInsets {
        return NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func setActionActive(_ active: Bool) {
        isActionActive = active
        if active {
            contentTintColor = AppColors.accent
        } else if !isButtonHovered {
            contentTintColor = AppColors.textLight
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let area = trackingArea { removeTrackingArea(area) }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isButtonHovered = true
        if isDanger {
            layer?.backgroundColor = AppColors.error.withAlphaComponent(0.2).cgColor
            contentTintColor = AppColors.error
        } else {
            layer?.backgroundColor = AppColors.accent.withAlphaComponent(0.2).cgColor
            contentTintColor = AppColors.accentLight
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isButtonHovered = false
        layer?.backgroundColor = AppColors.whiteOverlay8.cgColor
        contentTintColor = isActionActive ? AppColors.accent : AppColors.textLight
    }
}

// MARK: - List Action Button (28x28, transparent bg)

class ListActionButton: NSButton {
    private var trackingArea: NSTrackingArea?
    private var isButtonHovered = false
    private var isDanger = false
    private var isActionActive = false

    init(symbolName: String, label: String, isDanger: Bool = false) {
        self.isDanger = isDanger
        super.init(frame: .zero)
        if let img = NSImage(systemSymbolName: symbolName, accessibilityDescription: label) {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            self.image = img.withSymbolConfiguration(config)
        }
        setupButton()
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupButton() {
        isBordered = false
        bezelStyle = .shadowlessSquare
        imagePosition = .imageOnly
        wantsLayer = true
        layer?.cornerRadius = DesignSystem.ActionButton.listCornerRadius
        layer?.backgroundColor = NSColor.clear.cgColor
        contentTintColor = AppColors.textTertiary
    }

    func updateIcon(symbolName: String) {
        if let img = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .regular)
            self.image = img.withSymbolConfiguration(config)
        }
    }

    func setActionActive(_ active: Bool) {
        isActionActive = active
        if active {
            contentTintColor = AppColors.accent
        } else if !isButtonHovered {
            contentTintColor = AppColors.textTertiary
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let area = trackingArea { removeTrackingArea(area) }
        let area = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .activeAlways], owner: self, userInfo: nil)
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isButtonHovered = true
        if isDanger {
            layer?.backgroundColor = AppColors.error.withAlphaComponent(0.15).cgColor
            contentTintColor = AppColors.error
        } else {
            layer?.backgroundColor = AppColors.accent.withAlphaComponent(0.15).cgColor
            contentTintColor = AppColors.accent
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isButtonHovered = false
        layer?.backgroundColor = NSColor.clear.cgColor
        contentTintColor = isActionActive ? AppColors.accent : AppColors.textTertiary
    }
}
