import Cocoa

protocol PreviewOverlayViewDelegate: AnyObject {
    func previewOverlayDidRequestClose(_ overlay: PreviewOverlayView)
    func previewOverlay(_ overlay: PreviewOverlayView, didRequestCopyItem item: FileShelfItem)
    func previewOverlay(_ overlay: PreviewOverlayView, didTogglePinItem item: FileShelfItem)
    func previewOverlay(_ overlay: PreviewOverlayView, didRequestDeleteItem item: FileShelfItem)
}

/// Full-popover preview for image and text items. Presented over the shelf,
/// dismissed with Esc, the back button, or after delete.
class PreviewOverlayView: NSView {
    weak var delegate: PreviewOverlayViewDelegate?
    private(set) var item: FileShelfItem?

    // Header
    private let headerBar = NSView()
    private let backButton = HeaderButton(symbolName: "chevron.left", label: "Back")
    private let nameLabel = NSTextField()
    private let typeBadge = NSTextField()
    private let headerBorder = NSView()

    // Content
    private let contentContainer = NSView()
    private let imageView = NSImageView()
    private let textScrollView = NSScrollView()
    private let textView = NSTextView()
    private var fullImageLoadToken = UUID()

    // Footer
    private let footerBar = NSView()
    private let footerBorder = NSView()
    private let copyButton = GridActionButton(symbolName: "doc.on.doc", label: "Copy")
    private let pinButton = GridActionButton(symbolName: "pin", label: "Pin")
    private let deleteButton = GridActionButton(symbolName: "trash", label: "Delete", isDanger: true)

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    override var acceptsFirstResponder: Bool { true }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = AppColors.background.cgColor

        setupHeader()
        setupContent()
        setupFooter()
        setupConstraints()
    }

    private func setupHeader() {
        headerBar.wantsLayer = true
        headerBar.layer?.backgroundColor = AppColors.headerBackground.cgColor
        headerBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerBar)

        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.target = self
        backButton.action = #selector(backClicked)
        headerBar.addSubview(backButton)

        nameLabel.font = DesignSystem.Typography.subtitle
        nameLabel.textColor = AppColors.textPrimary
        // Long filenames must truncate, not widen the popover
        nameLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        nameLabel.lineBreakMode = .byTruncatingMiddle
        nameLabel.maximumNumberOfLines = 1
        nameLabel.usesSingleLineMode = true
        nameLabel.cell?.wraps = false
        nameLabel.cell?.lineBreakMode = .byTruncatingMiddle
        nameLabel.alignment = .left
        nameLabel.isEditable = false
        nameLabel.isBordered = false
        nameLabel.drawsBackground = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        headerBar.addSubview(nameLabel)

        typeBadge.font = DesignSystem.Typography.badge
        typeBadge.textColor = AppColors.accentLight
        typeBadge.alignment = .center
        typeBadge.isEditable = false
        typeBadge.isBordered = false
        typeBadge.wantsLayer = true
        typeBadge.drawsBackground = false
        typeBadge.layer?.backgroundColor = AppColors.accentBadgeBg.cgColor
        typeBadge.layer?.cornerRadius = DesignSystem.CornerRadius.sm
        typeBadge.translatesAutoresizingMaskIntoConstraints = false
        headerBar.addSubview(typeBadge)

        headerBorder.wantsLayer = true
        headerBorder.layer?.backgroundColor = AppColors.backgroundTertiary.cgColor
        headerBorder.translatesAutoresizingMaskIntoConstraints = false
        headerBar.addSubview(headerBorder)
    }

    private func setupContent() {
        contentContainer.wantsLayer = true
        contentContainer.layer?.backgroundColor = AppColors.previewBackground.cgColor
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentContainer)

        imageView.imageScaling = .scaleProportionallyDown
        imageView.imageAlignment = .alignCenter
        // The image's intrinsic size must never drive layout, or the popover
        // balloons to fit full-resolution images
        imageView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(1), for: .horizontal)
        imageView.setContentCompressionResistancePriority(NSLayoutConstraint.Priority(1), for: .vertical)
        imageView.setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .horizontal)
        imageView.setContentHuggingPriority(NSLayoutConstraint.Priority(1), for: .vertical)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        contentContainer.addSubview(imageView)

        textView.isEditable = false
        textView.isSelectable = true
        textView.drawsBackground = true
        textView.backgroundColor = AppColors.previewBackground
        textView.textColor = AppColors.textPrimary
        textView.textContainerInset = NSSize(width: 12, height: 12)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [.width]
        textView.textContainer?.widthTracksTextView = true

        textScrollView.documentView = textView
        textScrollView.hasVerticalScroller = true
        textScrollView.drawsBackground = false
        textScrollView.scrollerStyle = .overlay
        textScrollView.scrollerKnobStyle = .light
        textScrollView.translatesAutoresizingMaskIntoConstraints = false
        textScrollView.isHidden = true
        contentContainer.addSubview(textScrollView)
    }

    private func setupFooter() {
        footerBar.wantsLayer = true
        footerBar.layer?.backgroundColor = AppColors.headerBackground.cgColor
        footerBar.translatesAutoresizingMaskIntoConstraints = false
        addSubview(footerBar)

        footerBorder.wantsLayer = true
        footerBorder.layer?.backgroundColor = AppColors.backgroundTertiary.cgColor
        footerBorder.translatesAutoresizingMaskIntoConstraints = false
        footerBar.addSubview(footerBorder)

        for button in [copyButton, pinButton, deleteButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            footerBar.addSubview(button)
        }
        copyButton.target = self
        copyButton.action = #selector(copyClicked)
        pinButton.target = self
        pinButton.action = #selector(pinClicked)
        deleteButton.target = self
        deleteButton.action = #selector(deleteClicked)
    }

    private func setupConstraints() {
        let buttonSize = DesignSystem.ActionButton.gridSize
        NSLayoutConstraint.activate([
            headerBar.topAnchor.constraint(equalTo: topAnchor),
            headerBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerBar.heightAnchor.constraint(equalToConstant: DesignSystem.Header.height),

            backButton.leadingAnchor.constraint(equalTo: headerBar.leadingAnchor, constant: 12),
            backButton.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 26),
            backButton.heightAnchor.constraint(equalToConstant: 26),

            nameLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 8),
            nameLabel.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: typeBadge.leadingAnchor, constant: -8),

            typeBadge.trailingAnchor.constraint(equalTo: headerBar.trailingAnchor, constant: -16),
            typeBadge.centerYAnchor.constraint(equalTo: headerBar.centerYAnchor),
            typeBadge.widthAnchor.constraint(greaterThanOrEqualToConstant: 44),
            typeBadge.heightAnchor.constraint(equalToConstant: 18),

            headerBorder.leadingAnchor.constraint(equalTo: headerBar.leadingAnchor),
            headerBorder.trailingAnchor.constraint(equalTo: headerBar.trailingAnchor),
            headerBorder.bottomAnchor.constraint(equalTo: headerBar.bottomAnchor),
            headerBorder.heightAnchor.constraint(equalToConstant: 1),

            contentContainer.topAnchor.constraint(equalTo: headerBar.bottomAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: footerBar.topAnchor),

            imageView.topAnchor.constraint(equalTo: contentContainer.topAnchor, constant: DesignSystem.Spacing.md),
            imageView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor, constant: DesignSystem.Spacing.md),
            imageView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor, constant: -DesignSystem.Spacing.md),
            imageView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor, constant: -DesignSystem.Spacing.md),

            textScrollView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            textScrollView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            textScrollView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            textScrollView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor),

            footerBar.leadingAnchor.constraint(equalTo: leadingAnchor),
            footerBar.trailingAnchor.constraint(equalTo: trailingAnchor),
            footerBar.bottomAnchor.constraint(equalTo: bottomAnchor),
            footerBar.heightAnchor.constraint(equalToConstant: 52),

            footerBorder.leadingAnchor.constraint(equalTo: footerBar.leadingAnchor),
            footerBorder.trailingAnchor.constraint(equalTo: footerBar.trailingAnchor),
            footerBorder.topAnchor.constraint(equalTo: footerBar.topAnchor),
            footerBorder.heightAnchor.constraint(equalToConstant: 1),

            pinButton.centerXAnchor.constraint(equalTo: footerBar.centerXAnchor),
            pinButton.centerYAnchor.constraint(equalTo: footerBar.centerYAnchor),
            pinButton.widthAnchor.constraint(equalToConstant: buttonSize),
            pinButton.heightAnchor.constraint(equalToConstant: buttonSize),
            copyButton.trailingAnchor.constraint(equalTo: pinButton.leadingAnchor, constant: -DesignSystem.Spacing.sm),
            copyButton.centerYAnchor.constraint(equalTo: footerBar.centerYAnchor),
            copyButton.widthAnchor.constraint(equalToConstant: buttonSize),
            copyButton.heightAnchor.constraint(equalToConstant: buttonSize),
            deleteButton.leadingAnchor.constraint(equalTo: pinButton.trailingAnchor, constant: DesignSystem.Spacing.sm),
            deleteButton.centerYAnchor.constraint(equalTo: footerBar.centerYAnchor),
            deleteButton.widthAnchor.constraint(equalToConstant: buttonSize),
            deleteButton.heightAnchor.constraint(equalToConstant: buttonSize),
        ])
    }

    // MARK: - Configuration

    /// `initialImage` is the cell's already-loaded thumbnail so the overlay
    /// paints instantly; the full-resolution image replaces it asynchronously.
    func configure(with item: FileShelfItem, initialImage: NSImage?) {
        self.item = item

        nameLabel.stringValue = FileShelfItemCell.makeDisplayName(for: item)
        typeBadge.stringValue = "  \(item.itemType.displayName.uppercased())  "
        updatePinState()

        imageView.isHidden = true
        imageView.image = nil
        textScrollView.isHidden = true

        if item.isImage {
            imageView.isHidden = false
            imageView.image = initialImage
            loadFullResolutionImage(for: item)
        } else if let text = item.textContent {
            showText(text, isCode: item.looksLikeCode)
        } else if item.isTextReadableFile {
            showText("Loading…", isCode: false)
            loadTextFileContent(for: item)
        }
    }

    private func showText(_ text: String, isCode: Bool) {
        textScrollView.isHidden = false
        textView.font = isCode
            ? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
            : NSFont.systemFont(ofSize: 13, weight: .regular)
        textView.string = text
        textView.scroll(.zero)
    }

    private func loadFullResolutionImage(for item: FileShelfItem) {
        guard let fileURL = item.fileURL else { return }
        let token = UUID()
        fullImageLoadToken = token
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe)
            let image = data.flatMap { NSImage(data: $0) }
            DispatchQueue.main.async {
                guard let self = self,
                      self.fullImageLoadToken == token,
                      self.item?.id == item.id,
                      let image = image else { return }
                self.imageView.image = image
            }
        }
    }

    private func loadTextFileContent(for item: FileShelfItem) {
        guard let fileURL = item.fileURL else { return }
        let isCode = item.looksLikeCode
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let maxBytes = 1_048_576
            var text: String?
            var truncated = false
            if let data = try? Data(contentsOf: fileURL, options: .mappedIfSafe) {
                truncated = data.count > maxBytes
                let slice = truncated ? data.prefix(maxBytes) : data
                text = String(data: slice, encoding: .utf8)
                    ?? String(data: slice, encoding: .utf16)
                    ?? String(data: slice, encoding: .ascii)
            }
            DispatchQueue.main.async {
                guard let self = self, self.item?.id == item.id else { return }
                if var content = text {
                    if truncated { content += "\n\n… (truncated)" }
                    self.showText(content, isCode: isCode)
                } else {
                    self.showText("Couldn't load content", isCode: false)
                }
            }
        }
    }

    func updatePinState() {
        guard let item = item else { return }
        pinButton.updateIcon(symbolName: item.isPinned ? "pin.fill" : "pin")
        pinButton.setActionActive(item.isPinned)
    }

    // MARK: - Presentation

    func present(in container: NSView) {
        translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self, positioned: .above, relativeTo: nil)
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: container.topAnchor),
            leadingAnchor.constraint(equalTo: container.leadingAnchor),
            trailingAnchor.constraint(equalTo: container.trailingAnchor),
            bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        alphaValue = 0
        layer?.setAffineTransform(CGAffineTransform(scaleX: 0.96, y: 0.96))
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.18
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            ctx.allowsImplicitAnimation = true
            animator().alphaValue = 1
            layer?.setAffineTransform(.identity)
        }
        window?.makeFirstResponder(self)
    }

    func dismiss(completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            ctx.allowsImplicitAnimation = true
            animator().alphaValue = 0
        }, completionHandler: { [weak self] in
            self?.removeFromSuperview()
            completion?()
        })
    }

    // MARK: - Actions

    @objc private func backClicked() {
        delegate?.previewOverlayDidRequestClose(self)
    }

    @objc private func copyClicked() {
        guard let item = item else { return }
        copyButton.playCopyFeedback(duration: 0.6)
        delegate?.previewOverlay(self, didRequestCopyItem: item)
    }

    @objc private func pinClicked() {
        guard let item = item else { return }
        pinButton.playPinFeedback()
        delegate?.previewOverlay(self, didTogglePinItem: item)
        updatePinState()
    }

    @objc private func deleteClicked() {
        guard item != nil else { return }
        deleteButton.playDeleteFeedback()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
            guard let self = self, let item = self.item else { return }
            self.delegate?.previewOverlay(self, didRequestDeleteItem: item)
            self.delegate?.previewOverlayDidRequestClose(self)
        }
    }

    // MARK: - Keyboard

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 53, 49: // Esc, Space
            delegate?.previewOverlayDidRequestClose(self)
        case 36: // Return — copy, matching list behavior
            copyClicked()
        default:
            super.keyDown(with: event)
        }
    }

    override func cancelOperation(_ sender: Any?) {
        delegate?.previewOverlayDidRequestClose(self)
    }
}
