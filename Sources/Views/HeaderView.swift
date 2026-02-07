import Cocoa

protocol HeaderViewDelegate: AnyObject {
    func headerViewDidTapSettings(_ headerView: HeaderView)
    func headerViewDidTapQuit(_ headerView: HeaderView)
}

class HeaderView: NSView {
    weak var delegate: HeaderViewDelegate?

    private let titleLabel = NSTextField()
    private let settingsButton = HeaderButton(symbolName: "gearshape", label: "Settings")
    private let closeButton = HeaderButton(symbolName: "xmark", label: "Close")
    private let bottomBorder = NSView()

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
        layer?.backgroundColor = AppColors.headerBackground.cgColor

        setupTitle()
        setupButtons()
        setupBottomBorder()
        setupConstraints()
    }

    private func setupTitle() {
        titleLabel.stringValue = "ShelfSpace"
        titleLabel.font = DesignSystem.Typography.title
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }

    private func setupButtons() {
        settingsButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        addSubview(settingsButton)
        addSubview(closeButton)

        settingsButton.target = self
        settingsButton.action = #selector(settingsClicked)
        closeButton.target = self
        closeButton.action = #selector(closeClicked)
    }

    private func setupBottomBorder() {
        bottomBorder.wantsLayer = true
        bottomBorder.layer?.backgroundColor = AppColors.backgroundTertiary.cgColor
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBorder)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title: leading 16px, centered vertically
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Close button (rightmost): 26x26
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            closeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 26),
            closeButton.heightAnchor.constraint(equalToConstant: 26),

            // Settings button: gap-1 (4px) from close
            settingsButton.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -4),
            settingsButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            settingsButton.widthAnchor.constraint(equalToConstant: 26),
            settingsButton.heightAnchor.constraint(equalToConstant: 26),

            // Bottom border
            bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    // MARK: - Actions

    @objc private func settingsClicked() {
        delegate?.headerViewDidTapSettings(self)
    }

    @objc private func closeClicked() {
        delegate?.headerViewDidTapQuit(self)
    }

    // MARK: - Public

    func updateItemCount(_ count: Int) {
        // No-op: count display removed
    }

    func updateStatus(itemCount: Int, filterName: String? = nil) {
        // No-op: count display removed
    }

    func setStatus(_ status: String) {
        // No-op
    }
}

// MARK: - Header Button (26x26, transparent bg, hover #1E1E28)

class HeaderButton: NSButton {
    private var trackingArea: NSTrackingArea?
    private var isHovered = false

    init(symbolName: String, label: String) {
        super.init(frame: .zero)
        self.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: label)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    private func setupButton() {
        isBordered = false
        bezelStyle = .shadowlessSquare
        imagePosition = .imageOnly
        wantsLayer = true
        layer?.cornerRadius = DesignSystem.CornerRadius.sm
        layer?.backgroundColor = NSColor.clear.cgColor
        contentTintColor = AppColors.textTertiary

        if let img = image {
            let config = NSImage.SymbolConfiguration(pointSize: 15, weight: .regular)
            self.image = img.withSymbolConfiguration(config)
        }
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let area = trackingArea { removeTrackingArea(area) }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseEnteredAndExited, .activeAlways],
            owner: self, userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        isHovered = true
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.allowsImplicitAnimation = true
            self.layer?.backgroundColor = AppColors.backgroundTertiary.cgColor
            self.contentTintColor = AppColors.textPrimary
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHovered = false
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.allowsImplicitAnimation = true
            self.layer?.backgroundColor = NSColor.clear.cgColor
            self.contentTintColor = AppColors.textTertiary
        }
    }
}
