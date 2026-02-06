import Cocoa

protocol HeaderViewDelegate: AnyObject {
    func headerViewDidTapSettings(_ headerView: HeaderView)
    func headerViewDidTapQuit(_ headerView: HeaderView)
}

class HeaderView: NSView {
    weak var delegate: HeaderViewDelegate?

    private let iconBadge = NSView()
    private let iconImageView = NSImageView()
    private let titleLabel = NSTextField()
    private let countPill = NSTextField()
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

        setupIconBadge()
        setupTitle()
        setupCountPill()
        setupButtons()
        setupBottomBorder()
        setupConstraints()
    }

    private func setupIconBadge() {
        // 24x24 rounded-md container with accent bg
        iconBadge.wantsLayer = true
        iconBadge.layer?.backgroundColor = AppColors.accentBadgeBg.cgColor
        iconBadge.layer?.cornerRadius = DesignSystem.CornerRadius.sm
        iconBadge.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconBadge)

        // Clipboard icon 13px
        if let icon = NSImage(systemSymbolName: "clipboard", accessibilityDescription: "ShelfSpace") {
            iconImageView.image = icon
        }
        iconImageView.contentTintColor = AppColors.accent
        iconImageView.imageScaling = .scaleProportionallyUpOrDown
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconBadge.addSubview(iconImageView)
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

    private func setupCountPill() {
        countPill.stringValue = "0"
        countPill.font = DesignSystem.Typography.small
        countPill.textColor = AppColors.textTertiary
        countPill.alignment = .center
        countPill.isEditable = false
        countPill.isBordered = false
        countPill.wantsLayer = true
        countPill.layer?.backgroundColor = AppColors.backgroundTertiary.cgColor
        countPill.layer?.cornerRadius = 8
        countPill.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countPill)
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
            // Icon badge: 24x24, centered vertically, leading 16px
            iconBadge.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            iconBadge.centerYAnchor.constraint(equalTo: centerYAnchor),
            iconBadge.widthAnchor.constraint(equalToConstant: 24),
            iconBadge.heightAnchor.constraint(equalToConstant: 24),

            // Icon inside badge: 13px centered
            iconImageView.centerXAnchor.constraint(equalTo: iconBadge.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBadge.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 13),
            iconImageView.heightAnchor.constraint(equalToConstant: 13),

            // Title: gap-2.5 (10px) from icon badge
            titleLabel.leadingAnchor.constraint(equalTo: iconBadge.trailingAnchor, constant: 10),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            // Count pill: gap-2.5 (10px) from title
            countPill.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 10),
            countPill.centerYAnchor.constraint(equalTo: centerYAnchor),
            countPill.heightAnchor.constraint(equalToConstant: 18),
            countPill.widthAnchor.constraint(greaterThanOrEqualToConstant: 24),

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
        countPill.stringValue = "\(count)"
    }

    func updateStatus(itemCount: Int, filterName: String? = nil) {
        updateItemCount(itemCount)
    }

    func setStatus(_ status: String) {
        // No-op, header only shows count pill now
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
