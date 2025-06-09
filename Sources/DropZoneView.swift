import Cocoa

protocol DropZoneViewDelegate: AnyObject {
    func dropZoneView(_ dropZoneView: DropZoneView, didReceiveFiles urls: [URL])
}

class DropZoneView: NSView {
    weak var delegate: DropZoneViewDelegate?
    
    private var isDragActive = false
    private let borderLayer = CAShapeLayer()
    private let iconImageView = NSImageView()
    private let instructionLabel = NSTextField()
    
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
    
    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = 8
        layer?.backgroundColor = NSColor.controlBackgroundColor.withAlphaComponent(0.5).cgColor
        
        // Setup border layer
        borderLayer.strokeColor = AppColors.primary.withAlphaComponent(0.6).cgColor
        borderLayer.fillColor = NSColor.clear.cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineDashPattern = [8, 4]
        layer?.addSublayer(borderLayer)
        
        // Setup icon
        iconImageView.image = NSImage(systemSymbolName: "plus.circle", accessibilityDescription: "Add files")
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(iconImageView)
        
        // Setup instruction label
        instructionLabel.stringValue = "Drop files here or copy content to clipboard"
        instructionLabel.font = NSFont.systemFont(ofSize: 13)
        instructionLabel.textColor = AppColors.secondaryText
        instructionLabel.alignment = .center
        instructionLabel.isEditable = false
        instructionLabel.isBordered = false
        instructionLabel.backgroundColor = NSColor.clear
        instructionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(instructionLabel)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -10),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            instructionLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 4),
            instructionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            instructionLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8)
        ])
        
        updateAppearance()
    }
    
    private func setupDragAndDrop() {
        registerForDraggedTypes([.fileURL, .URL])
    }
    
    override func layout() {
        super.layout()
        updateBorderPath()
    }
    
    private func updateBorderPath() {
        let path = NSBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1), xRadius: 8, yRadius: 8)
        if #available(macOS 14.0, *) {
            borderLayer.path = path.cgPath
        } else {
            // Fallback for macOS 13
            let cgPath = CGMutablePath()
            cgPath.addRoundedRect(in: bounds.insetBy(dx: 1, dy: 1), cornerWidth: 8, cornerHeight: 8)
            borderLayer.path = cgPath
        }
    }
    
    private func updateAppearance() {
        if isDragActive {
            layer?.backgroundColor = AppColors.primary.withAlphaComponent(0.15).cgColor
            borderLayer.opacity = 1.0
            iconImageView.image = NSImage(systemSymbolName: "plus.circle.fill", accessibilityDescription: "Add files")
            iconImageView.contentTintColor = AppColors.primary
            instructionLabel.stringValue = "Release to add content"
        } else {
            layer?.backgroundColor = AppColors.background.withAlphaComponent(0.5).cgColor
            borderLayer.opacity = 0.4
            iconImageView.image = NSImage(systemSymbolName: "plus.circle", accessibilityDescription: "Add files")
            iconImageView.contentTintColor = AppColors.secondaryText
            instructionLabel.stringValue = "Drop files here or copy content to clipboard"
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
            
            // Animate feedback
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
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            context.allowsImplicitAnimation = true
            self.layer?.setAffineTransform(CGAffineTransform(scaleX: 1.05, y: 1.05))
        } completionHandler: {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.15
                context.allowsImplicitAnimation = true
                self.layer?.setAffineTransform(CGAffineTransform.identity)
            }
        }
    }
} 