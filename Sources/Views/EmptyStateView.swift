import Cocoa

/// Empty state view shown when no items are present
class EmptyStateView: NSView {
    // MARK: - UI Components

    private let containerStack = NSStackView()
    private let iconContainer = NSView()
    private let iconImageView = NSImageView()
    private let plusIndicators: [NSView] = []
    private let titleLabel = NSTextField()
    private let subtitleLabel = NSTextField()
    private let supportedTypesLabel = NSTextField()

    private var dashedBorderLayer: CAShapeLayer?

    // MARK: - Initialization

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
        layer?.backgroundColor = NSColor.clear.cgColor

        setupIconContainer()
        setupLabels()
        setupLayout()
    }

    private func setupIconContainer() {
        // Icon container with dashed border
        iconContainer.wantsLayer = true
        iconContainer.layer?.cornerRadius = DesignSystem.GridCard.cornerRadius
        iconContainer.layer?.backgroundColor = NSColor.clear.cgColor
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconContainer)

        // Dashed border
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = AppColors.border.cgColor
        borderLayer.fillColor = NSColor.clear.cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineDashPattern = [8, 4]
        iconContainer.layer?.addSublayer(borderLayer)
        dashedBorderLayer = borderLayer

        // Folder icon
        iconImageView.image = NSImage(systemSymbolName: "folder.badge.plus", accessibilityDescription: "Add files")
        iconImageView.contentTintColor = AppColors.accent
        iconImageView.imageScaling = .scaleProportionallyUpOrDown
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 36),
            iconImageView.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func setupLabels() {
        // Title label
        titleLabel.stringValue = "Drop files here or"
        titleLabel.font = DesignSystem.Typography.subtitle
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.alignment = .center
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        // Subtitle label
        subtitleLabel.stringValue = "copy content to clipboard"
        subtitleLabel.font = DesignSystem.Typography.body
        subtitleLabel.textColor = AppColors.textSecondary
        subtitleLabel.alignment = .center
        subtitleLabel.isEditable = false
        subtitleLabel.isBordered = false
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)

        // Supported types label
        supportedTypesLabel.stringValue = "Supports images, text, files up to 200MB"
        supportedTypesLabel.font = DesignSystem.Typography.small
        supportedTypesLabel.textColor = AppColors.textTertiary
        supportedTypesLabel.alignment = .center
        supportedTypesLabel.isEditable = false
        supportedTypesLabel.isBordered = false
        supportedTypesLabel.backgroundColor = .clear
        supportedTypesLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(supportedTypesLabel)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            // Icon container
            iconContainer.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconContainer.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            iconContainer.widthAnchor.constraint(equalToConstant: 100),
            iconContainer.heightAnchor.constraint(equalToConstant: 100),

            // Title
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.topAnchor.constraint(equalTo: iconContainer.bottomAnchor, constant: DesignSystem.Spacing.lg),

            // Subtitle
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.xs),

            // Supported types
            supportedTypesLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            supportedTypesLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: DesignSystem.Spacing.sm)
        ])
    }

    // MARK: - Layout

    override func layout() {
        super.layout()
        updateDashedBorder()
    }

    private func updateDashedBorder() {
        guard let borderLayer = dashedBorderLayer else { return }

        let path = NSBezierPath(
            roundedRect: iconContainer.bounds.insetBy(dx: 1, dy: 1),
            xRadius: DesignSystem.GridCard.cornerRadius,
            yRadius: DesignSystem.GridCard.cornerRadius
        )
        borderLayer.path = path.cgPath
        borderLayer.frame = iconContainer.bounds
    }

    // MARK: - Animation

    func startIdleAnimation() {
        // Subtle pulse animation on the icon
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
        pulseAnimation.fromValue = 1.0
        pulseAnimation.toValue = 1.05
        pulseAnimation.duration = 2.0
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = .infinity
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)

        iconImageView.layer?.add(pulseAnimation, forKey: "idlePulse")
    }

    func stopIdleAnimation() {
        iconImageView.layer?.removeAnimation(forKey: "idlePulse")
    }

    // MARK: - Drop Active State

    func setDropActive(_ active: Bool) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = AnimationHelper.Duration.fast
            context.allowsImplicitAnimation = true

            if active {
                // Highlight state
                iconContainer.layer?.backgroundColor = AppColors.accentMuted.cgColor
                dashedBorderLayer?.strokeColor = AppColors.accent.cgColor
                iconImageView.contentTintColor = AppColors.accentLight

                // Scale up icon slightly
                iconImageView.layer?.setAffineTransform(CGAffineTransform(scaleX: 1.1, y: 1.1))

                titleLabel.stringValue = "Release to add"
                titleLabel.textColor = AppColors.accent

                // Add animated dashed border
                if let borderLayer = dashedBorderLayer {
                    AnimationHelper.addAnimatedDashedBorder(to: borderLayer, color: AppColors.accent.cgColor)
                }
            } else {
                // Normal state
                iconContainer.layer?.backgroundColor = NSColor.clear.cgColor
                dashedBorderLayer?.strokeColor = AppColors.border.cgColor
                iconImageView.contentTintColor = AppColors.accent

                // Reset icon scale
                iconImageView.layer?.setAffineTransform(.identity)

                titleLabel.stringValue = "Drop files here or"
                titleLabel.textColor = AppColors.textPrimary

                // Remove animated dashed border
                if let borderLayer = dashedBorderLayer {
                    AnimationHelper.removeAnimatedDashedBorder(from: borderLayer)
                }
            }
        }
    }
}
