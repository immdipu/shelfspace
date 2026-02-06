import Cocoa

protocol ToolbarViewDelegate: AnyObject {
    func toolbarViewDidTapClearAll(_ toolbarView: ToolbarView)
    func toolbarViewDidTapSelectAll(_ toolbarView: ToolbarView)
    func toolbarViewDidTapExport(_ toolbarView: ToolbarView)
}

class ToolbarView: NSView {
    weak var delegate: ToolbarViewDelegate?

    private let keyboardHintContainer = NSView()
    private let actionsContainer = NSView()
    private let selectAllButton = ToolbarIconButton(symbolName: "checkmark.circle", label: "Select All")
    private let exportButton = ToolbarIconButton(symbolName: "square.and.arrow.down", label: "Export")
    private let divider = NSView()
    private let clearAllButton = ToolbarIconButton(symbolName: "trash", label: "Clear All", isDanger: true)
    private let topBorder = NSView()

    private var heightConstraint: NSLayoutConstraint?
    private var isVisible = false

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = AppColors.toolbarBackground.cgColor

        setupTopBorder()
        setupKeyboardHint()
        setupActions()
        setupConstraints()
    }

    private func setupTopBorder() {
        topBorder.wantsLayer = true
        topBorder.layer?.backgroundColor = AppColors.whiteOverlay5.cgColor
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topBorder)
    }

    private func setupKeyboardHint() {
        keyboardHintContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(keyboardHintContainer)

        // Keyboard icon
        let keyboardIcon = NSImageView()
        if let img = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "Keyboard") {
            let config = NSImage.SymbolConfiguration(pointSize: 11, weight: .regular)
            keyboardIcon.image = img.withSymbolConfiguration(config)
        }
        keyboardIcon.contentTintColor = AppColors.textDarkest
        keyboardIcon.translatesAutoresizingMaskIntoConstraints = false
        keyboardHintContainer.addSubview(keyboardIcon)

        // Cmd key
        let cmdKey = createKbd("⌘")
        keyboardHintContainer.addSubview(cmdKey)

        // V key
        let vKey = createKbd("V")
        keyboardHintContainer.addSubview(vKey)

        // "to paste" text
        let pasteLabel = NSTextField()
        pasteLabel.stringValue = "to paste"
        pasteLabel.font = DesignSystem.Typography.badge
        pasteLabel.textColor = AppColors.textDarkest
        pasteLabel.isEditable = false
        pasteLabel.isBordered = false
        pasteLabel.drawsBackground = false
        pasteLabel.translatesAutoresizingMaskIntoConstraints = false
        keyboardHintContainer.addSubview(pasteLabel)

        NSLayoutConstraint.activate([
            keyboardIcon.leadingAnchor.constraint(equalTo: keyboardHintContainer.leadingAnchor),
            keyboardIcon.centerYAnchor.constraint(equalTo: keyboardHintContainer.centerYAnchor),
            keyboardIcon.widthAnchor.constraint(equalToConstant: 13),
            keyboardIcon.heightAnchor.constraint(equalToConstant: 13),

            cmdKey.leadingAnchor.constraint(equalTo: keyboardIcon.trailingAnchor, constant: 6),
            cmdKey.centerYAnchor.constraint(equalTo: keyboardHintContainer.centerYAnchor),

            vKey.leadingAnchor.constraint(equalTo: cmdKey.trailingAnchor, constant: 4),
            vKey.centerYAnchor.constraint(equalTo: keyboardHintContainer.centerYAnchor),

            pasteLabel.leadingAnchor.constraint(equalTo: vKey.trailingAnchor, constant: 4),
            pasteLabel.centerYAnchor.constraint(equalTo: keyboardHintContainer.centerYAnchor),
            pasteLabel.trailingAnchor.constraint(equalTo: keyboardHintContainer.trailingAnchor),
        ])
    }

    private func createKbd(_ text: String) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = AppColors.whiteOverlay5.cgColor
        container.layer?.cornerRadius = 3
        container.layer?.borderWidth = 1
        container.layer?.borderColor = AppColors.whiteOverlay6.cgColor
        container.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField()
        label.stringValue = text
        label.font = DesignSystem.Typography.badge
        label.textColor = AppColors.textDim
        label.alignment = .center
        label.isEditable = false
        label.isBordered = false
        label.drawsBackground = false
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)

        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 16),
            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 18),
            label.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -4),
        ])

        return container
    }

    private func setupActions() {
        actionsContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(actionsContainer)

        for button in [selectAllButton, exportButton, clearAllButton] {
            button.translatesAutoresizingMaskIntoConstraints = false
            actionsContainer.addSubview(button)
        }

        selectAllButton.target = self
        selectAllButton.action = #selector(selectAllClicked)
        exportButton.target = self
        exportButton.action = #selector(exportClicked)
        clearAllButton.target = self
        clearAllButton.action = #selector(clearAllClicked)

        // Divider between export and clear
        divider.wantsLayer = true
        divider.layer?.backgroundColor = AppColors.whiteOverlay6.cgColor
        divider.translatesAutoresizingMaskIntoConstraints = false
        actionsContainer.addSubview(divider)

        NSLayoutConstraint.activate([
            selectAllButton.leadingAnchor.constraint(equalTo: actionsContainer.leadingAnchor),
            selectAllButton.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            selectAllButton.widthAnchor.constraint(equalToConstant: 28),
            selectAllButton.heightAnchor.constraint(equalToConstant: 28),

            exportButton.leadingAnchor.constraint(equalTo: selectAllButton.trailingAnchor, constant: 2),
            exportButton.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            exportButton.widthAnchor.constraint(equalToConstant: 28),
            exportButton.heightAnchor.constraint(equalToConstant: 28),

            divider.leadingAnchor.constraint(equalTo: exportButton.trailingAnchor, constant: 4),
            divider.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            divider.widthAnchor.constraint(equalToConstant: 1),
            divider.heightAnchor.constraint(equalToConstant: 12),

            clearAllButton.leadingAnchor.constraint(equalTo: divider.trailingAnchor, constant: 4),
            clearAllButton.centerYAnchor.constraint(equalTo: actionsContainer.centerYAnchor),
            clearAllButton.widthAnchor.constraint(equalToConstant: 28),
            clearAllButton.heightAnchor.constraint(equalToConstant: 28),
            clearAllButton.trailingAnchor.constraint(equalTo: actionsContainer.trailingAnchor),
        ])
    }

    private func setupConstraints() {
        heightConstraint = heightAnchor.constraint(equalToConstant: 0)
        heightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            topBorder.topAnchor.constraint(equalTo: topAnchor),
            topBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            topBorder.heightAnchor.constraint(equalToConstant: 1),

            keyboardHintContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            keyboardHintContainer.centerYAnchor.constraint(equalTo: centerYAnchor),

            actionsContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            actionsContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    // MARK: - Actions

    @objc private func selectAllClicked() {
        delegate?.toolbarViewDidTapSelectAll(self)
    }

    @objc private func exportClicked() {
        delegate?.toolbarViewDidTapExport(self)
    }

    @objc private func clearAllClicked() {
        let alert = NSAlert()
        alert.messageText = "Clear All Items?"
        alert.informativeText = "This will remove all unpinned items. Pinned items will be kept."
        alert.addButton(withTitle: "Clear")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = .warning
        if alert.runModal() == .alertFirstButtonReturn {
            delegate?.toolbarViewDidTapClearAll(self)
        }
    }

    // MARK: - Public

    func show(animated: Bool = true) {
        guard !isVisible else { return }
        isVisible = true
        let duration = animated ? AnimationHelper.Duration.normal : 0
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = duration
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            heightConstraint?.animator().constant = DesignSystem.Header.toolbarHeight
        }
    }

    func hide(animated: Bool = true) {
        guard isVisible else { return }
        isVisible = false
        let duration = animated ? AnimationHelper.Duration.normal : 0
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = duration
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            heightConstraint?.animator().constant = 0
        }
    }

    func updateItemCount(_ count: Int) {
        selectAllButton.isEnabled = count > 0
        exportButton.isEnabled = count > 0
        clearAllButton.isEnabled = count > 0
    }
}

// MARK: - Toolbar Icon Button (28x28 with hover and tooltip)

class ToolbarIconButton: NSButton {
    private var trackingArea: NSTrackingArea?
    private var isButtonHovered = false
    private var isDanger = false
    private let tooltipLabel = NSTextField()

    init(symbolName: String, label: String, isDanger: Bool = false) {
        self.isDanger = isDanger
        super.init(frame: .zero)
        if let img = NSImage(systemSymbolName: symbolName, accessibilityDescription: label) {
            let config = NSImage.SymbolConfiguration(pointSize: 13.5, weight: .regular)
            self.image = img.withSymbolConfiguration(config)
        }
        self.toolTip = label
        setupButton()
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    private func setupButton() {
        isBordered = false
        bezelStyle = .shadowlessSquare
        imagePosition = .imageOnly
        wantsLayer = true
        layer?.cornerRadius = DesignSystem.CornerRadius.sm
        layer?.backgroundColor = NSColor.clear.cgColor
        contentTintColor = isDanger ? AppColors.textTertiary : AppColors.textDim
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
            layer?.backgroundColor = AppColors.error.withAlphaComponent(0.12).cgColor
            contentTintColor = AppColors.errorLight
        } else {
            layer?.backgroundColor = AppColors.whiteOverlay6.cgColor
            contentTintColor = AppColors.textLight
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isButtonHovered = false
        layer?.backgroundColor = NSColor.clear.cgColor
        contentTintColor = isDanger ? AppColors.textTertiary : AppColors.textDim
    }
}

// MARK: - Legacy ToolbarButton compatibility

class ToolbarButton: NSButton {
    init(title: String, symbolName: String) {
        super.init(frame: .zero)
        self.title = title
        self.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: title)
        self.imagePosition = .imageLeading
        self.font = DesignSystem.Typography.caption
        self.isBordered = false
        wantsLayer = true
        layer?.cornerRadius = DesignSystem.CornerRadius.sm
        layer?.backgroundColor = AppColors.backgroundTertiary.cgColor
        contentTintColor = AppColors.textSecondary
    }

    required init?(coder: NSCoder) { super.init(coder: coder) }

    func setDanger(_ danger: Bool) {
        if danger {
            contentTintColor = AppColors.error.withAlphaComponent(0.8)
        }
    }

    override var intrinsicContentSize: NSSize {
        let size = super.intrinsicContentSize
        return NSSize(width: size.width + DesignSystem.Spacing.md, height: size.height)
    }
}
