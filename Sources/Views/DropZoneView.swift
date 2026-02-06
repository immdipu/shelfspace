import Cocoa

protocol DropZoneViewDelegate: AnyObject {
    func dropZoneView(_ dropZoneView: DropZoneView, didReceiveFiles urls: [URL])
}

/// Modern drop zone overlay with animated border
class DropZoneView: NSView {
    weak var delegate: DropZoneViewDelegate?

    private var isDragActive = false
    private let borderLayer = CAShapeLayer()
    private let overlayLayer = CALayer()
    private let iconImageView = NSImageView()
    private let instructionLabel = NSTextField()

    // MARK: - Initialization

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        setupDragAndDrop()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupDragAndDrop()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
        setupDragAndDrop()
    }

    // MARK: - Setup

    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = DesignSystem.CornerRadius.md
        layer?.backgroundColor = NSColor.clear.cgColor

        // Overlay layer (tinted background when active)
        overlayLayer.backgroundColor = AppColors.accent.withAlphaComponent(0.08).cgColor
        overlayLayer.cornerRadius = DesignSystem.CornerRadius.md
        overlayLayer.opacity = 0
        layer?.addSublayer(overlayLayer)

        // Border layer with dashed pattern
        borderLayer.strokeColor = AppColors.accent.cgColor
        borderLayer.fillColor = NSColor.clear.cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineDashPattern = [8, 4]
        borderLayer.cornerRadius = DesignSystem.CornerRadius.md
        borderLayer.opacity = 0
        layer?.addSublayer(borderLayer)

        // Icon
        iconImageView.image = NSImage(systemSymbolName: "arrow.down.circle", accessibilityDescription: "Drop here")
        iconImageView.contentTintColor = AppColors.accent
        iconImageView.imageScaling = .scaleProportionallyUpOrDown
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.alphaValue = 0
        addSubview(iconImageView)

        // Instruction label
        instructionLabel.stringValue = "Release to add content"
        instructionLabel.font = DesignSystem.Typography.subtitle
        instructionLabel.textColor = AppColors.accent
        instructionLabel.alignment = .center
        instructionLabel.isEditable = false
        instructionLabel.isBordered = false
        instructionLabel.backgroundColor = .clear
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        instructionLabel.alphaValue = 0
        addSubview(instructionLabel)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -15),
            iconImageView.widthAnchor.constraint(equalToConstant: 48),
            iconImageView.heightAnchor.constraint(equalToConstant: 48),

            instructionLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            instructionLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: DesignSystem.Spacing.sm)
        ])
    }

    private func setupDragAndDrop() {
        registerForDraggedTypes([.fileURL, .URL, .string])
    }

    // MARK: - Layout

    override func layout() {
        super.layout()
        updateBorderPath()
        overlayLayer.frame = bounds
    }

    private func updateBorderPath() {
        let path = NSBezierPath(
            roundedRect: bounds.insetBy(dx: 2, dy: 2),
            xRadius: DesignSystem.CornerRadius.md,
            yRadius: DesignSystem.CornerRadius.md
        )
        borderLayer.path = path.cgPath
        borderLayer.frame = bounds
    }

    // MARK: - Appearance

    private func updateAppearance(animated: Bool = true) {
        let duration = animated ? AnimationHelper.Duration.fast : 0

        if isDragActive {
            // Show overlay and border
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                context.allowsImplicitAnimation = true

                overlayLayer.opacity = 1.0
                borderLayer.opacity = 1.0
                iconImageView.alphaValue = 1.0
                instructionLabel.alphaValue = 1.0
            }

            // Start animated dashed border
            AnimationHelper.addAnimatedDashedBorder(to: borderLayer, color: AppColors.accent.cgColor)

            // Scale up icon
            let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
            scaleAnimation.fromValue = 0.8
            scaleAnimation.toValue = 1.0
            scaleAnimation.duration = duration
            scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
            iconImageView.layer?.add(scaleAnimation, forKey: "scaleIn")
        } else {
            // Hide overlay and border
            NSAnimationContext.runAnimationGroup { context in
                context.duration = duration
                context.allowsImplicitAnimation = true

                overlayLayer.opacity = 0.0
                borderLayer.opacity = 0.0
                iconImageView.alphaValue = 0.0
                instructionLabel.alphaValue = 0.0
            }

            // Stop animated dashed border
            AnimationHelper.removeAnimatedDashedBorder(from: borderLayer)
        }
    }

    // MARK: - Drag and Drop

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if canAcceptDrag(sender) {
            isDragActive = true
            updateAppearance()
            return .copy
        }
        return []
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return canAcceptDrag(sender) ? .copy : []
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        isDragActive = false
        updateAppearance()
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        isDragActive = false
        updateAppearance()

        let pasteboard = sender.draggingPasteboard
        var urls: [URL] = []

        // Get file URLs
        if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            urls.append(contentsOf: fileURLs.filter { $0.isFileURL })
        }

        // Handle string paths
        if let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
            for string in strings {
                let url = URL(fileURLWithPath: string)
                if FileManager.default.fileExists(atPath: url.path) {
                    urls.append(url)
                }
            }
        }

        if !urls.isEmpty {
            delegate?.dropZoneView(self, didReceiveFiles: urls)
            animateSuccess()
            return true
        }

        return false
    }

    private func canAcceptDrag(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard

        // Check for file URLs
        if pasteboard.availableType(from: [.fileURL, .URL]) != nil {
            return true
        }

        // Check for string paths
        if let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
            return strings.contains { FileManager.default.fileExists(atPath: $0) }
        }

        return false
    }

    private func animateSuccess() {
        // Brief scale animation to indicate successful drop
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        scaleAnimation.values = [1.0, 1.05, 1.0]
        scaleAnimation.keyTimes = [0, 0.5, 1.0]
        scaleAnimation.duration = 0.3
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer?.add(scaleAnimation, forKey: "successPulse")
    }
}
