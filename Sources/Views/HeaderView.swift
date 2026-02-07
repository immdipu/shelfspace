import Cocoa

protocol HeaderViewDelegate: AnyObject {
    func headerViewDidTapSettings(_ headerView: HeaderView)
    func headerViewDidTapQuit(_ headerView: HeaderView)
}

class HeaderView: NSView {
    weak var delegate: HeaderViewDelegate?

    private let logoView = NSView()
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
        // Logo icon
        logoView.wantsLayer = true
        logoView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(logoView)
        drawShelfSpaceLogo(in: logoView, size: 22)

        titleLabel.stringValue = "ShelfSpace"
        titleLabel.font = DesignSystem.Typography.title
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)
    }

    private func drawShelfSpaceLogo(in container: NSView, size: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            NSColor(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0, alpha: 1.0).cgColor,
            NSColor(red: 0x7C/255.0, green: 0x3A/255.0, blue: 0xED/255.0, alpha: 1.0).cgColor,
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: size, height: size)
        gradient.cornerRadius = size * 0.22

        container.layer?.addSublayer(gradient)

        let barSpecs: [(yFraction: CGFloat, widthFraction: CGFloat, opacity: Float)] = [
            (0.62, 0.64, 0.95),
            (0.44, 0.44, 0.70),
            (0.26, 0.54, 0.45),
        ]

        for spec in barSpecs {
            let bar = CALayer()
            let barW = size * spec.widthFraction
            let barH = size * 0.13
            let barX = size * 0.18
            let barY = size - (size * spec.yFraction) - barH
            bar.frame = CGRect(x: barX, y: barY, width: barW, height: barH)
            bar.backgroundColor = NSColor.white.cgColor
            bar.cornerRadius = barH * 0.31
            bar.opacity = spec.opacity
            gradient.addSublayer(bar)
        }
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
            // Logo: leading 16px, centered vertically
            logoView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            logoView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoView.widthAnchor.constraint(equalToConstant: 22),
            logoView.heightAnchor.constraint(equalToConstant: 22),

            // Title: after logo with 8px gap, centered vertically
            titleLabel.leadingAnchor.constraint(equalTo: logoView.trailingAnchor, constant: 8),
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
