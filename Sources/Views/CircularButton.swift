import Cocoa

/// Custom circular button class for rounded action buttons
class CircularButton: NSButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCircularButton()
    }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupCircularButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCircularButton()
    }

    private func setupCircularButton() {
        wantsLayer = true
        layer?.masksToBounds = true
    }

    override func layout() {
        super.layout()
        // Ensure the button is always perfectly circular
        let size = min(bounds.width, bounds.height)
        layer?.cornerRadius = size / 2.0
    }

    override var intrinsicContentSize: NSSize {
        let size = super.intrinsicContentSize
        let maxDimension = max(size.width, size.height, 24) // Minimum 24x24
        return NSSize(width: maxDimension, height: maxDimension)
    }

    override func setFrameSize(_ newSize: NSSize) {
        // Force square frame
        let size = max(newSize.width, newSize.height)
        super.setFrameSize(NSSize(width: size, height: size))
    }
}
