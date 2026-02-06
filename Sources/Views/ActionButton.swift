import Cocoa

class ActionButton: NSButton {
    private var trackingArea: NSTrackingArea?
    private var isHovered = false

    var normalBackgroundColor: NSColor = AppColors.backgroundTertiary {
        didSet { if !isHovered { layer?.backgroundColor = normalBackgroundColor.cgColor } }
    }
    var hoverBackgroundColor: NSColor = AppColors.accent
    var normalTintColor: NSColor = AppColors.textSecondary
    var hoverTintColor: NSColor = AppColors.textPrimary

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    convenience init(symbolName: String, accessibilityLabel: String) {
        self.init(frame: .zero)
        self.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: accessibilityLabel)
    }

    func setupButton() {
        wantsLayer = true
        isBordered = false
        bezelStyle = .shadowlessSquare
        imagePosition = .imageOnly
        layer?.cornerRadius = DesignSystem.CornerRadius.sm
        layer?.backgroundColor = normalBackgroundColor.cgColor
        contentTintColor = normalTintColor
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
            self.layer?.backgroundColor = hoverBackgroundColor.cgColor
            self.contentTintColor = hoverTintColor
        }
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        isHovered = false
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.allowsImplicitAnimation = true
            self.layer?.backgroundColor = normalBackgroundColor.cgColor
            self.contentTintColor = normalTintColor
        }
    }

    func setActive(_ active: Bool) {
        if active {
            layer?.backgroundColor = AppColors.accent.cgColor
            contentTintColor = AppColors.textPrimary
        } else {
            layer?.backgroundColor = normalBackgroundColor.cgColor
            contentTintColor = normalTintColor
        }
    }
}

class CircularActionButton: ActionButton {
    override func layout() {
        super.layout()
        layer?.cornerRadius = bounds.width / 2
    }
}

class DangerActionButton: ActionButton {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupDangerColors()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDangerColors()
    }

    convenience init(symbolName: String, accessibilityLabel: String) {
        self.init(frame: .zero)
        self.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: accessibilityLabel)
    }

    private func setupDangerColors() {
        hoverBackgroundColor = AppColors.error
        hoverTintColor = AppColors.textPrimary
    }
}
