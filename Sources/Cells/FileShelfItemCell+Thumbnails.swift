import Cocoa

// MARK: - Thumbnail & Preview Image Generation
extension FileShelfItemCell {
    func loadThumbnail(for item: FileShelfItem) {
        // Thumbnail loading is now handled in configure() via setupPreviewContent()
    }

    func createThumbnail(from image: NSImage, size: NSSize) -> NSImage {
        let thumbnail = NSImage(size: size)
        thumbnail.lockFocus()
        image.draw(in: NSRect(origin: .zero, size: size), from: NSRect.zero, operation: .copy, fraction: 1.0)
        thumbnail.unlockFocus()
        return thumbnail
    }

    /// Renders text content as an image to display in the preview area via thumbnailImageView.
    /// This is more reliable than adding NSTextField subviews to previewArea.
    func createTextPreviewImage(text: String, size: NSSize? = nil) -> NSImage {
        let previewSize = size ?? NSSize(width: max(previewArea.bounds.width, 200), height: max(previewArea.bounds.height, 100))
        let image = NSImage(size: previewSize)
        image.lockFocus()

        // Background
        AppColors.previewBackground.setFill()
        NSRect(origin: .zero, size: previewSize).fill()

        // Text content
        let truncatedText = String(text.prefix(500))
        let fontSize: CGFloat = previewSize.width < 150 ? 9 : 11
        let font = NSFont.monospacedSystemFont(ofSize: fontSize, weight: .regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping
        paragraphStyle.lineSpacing = 2

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: AppColors.textSecondary,
            .paragraphStyle: paragraphStyle,
        ]

        let padding: CGFloat = 10
        let textRect = NSRect(
            x: padding,
            y: padding,
            width: previewSize.width - padding * 2,
            height: previewSize.height - padding * 2
        )
        truncatedText.draw(in: textRect, withAttributes: attributes)

        image.unlockFocus()
        return image
    }

    /// Renders a file-type icon as an image to display in the preview area via thumbnailImageView.
    func createFileIconPreviewImage(iconName: String, fileSize: String, size: NSSize? = nil) -> NSImage {
        let previewSize = size ?? NSSize(width: max(previewArea.bounds.width, 200), height: max(previewArea.bounds.height, 100))
        let image = NSImage(size: previewSize)
        image.lockFocus()

        // Background
        AppColors.previewBackground.setFill()
        NSRect(origin: .zero, size: previewSize).fill()

        // Draw icon centered
        if let icon = NSImage(systemSymbolName: iconName, accessibilityDescription: nil) {
            let config = NSImage.SymbolConfiguration(pointSize: 28, weight: .medium)
            if let configured = icon.withSymbolConfiguration(config) {
                let iconSize = configured.size
                let iconX = (previewSize.width - iconSize.width) / 2
                let iconY = (previewSize.height - iconSize.height) / 2 + 8

                // Draw icon bg circle
                let bgSize: CGFloat = 48
                let bgRect = NSRect(
                    x: (previewSize.width - bgSize) / 2,
                    y: (previewSize.height - bgSize) / 2 + 8,
                    width: bgSize,
                    height: bgSize
                )
                let bgPath = NSBezierPath(roundedRect: bgRect, xRadius: 10, yRadius: 10)
                AppColors.accent.withAlphaComponent(0.12).setFill()
                bgPath.fill()

                // Draw icon
                configured.draw(
                    in: NSRect(x: iconX, y: iconY, width: iconSize.width, height: iconSize.height),
                    from: .zero,
                    operation: .sourceOver,
                    fraction: 1.0
                )
            }
        }

        // Draw file size text below
        if !fileSize.isEmpty {
            let font = NSFont.systemFont(ofSize: 10, weight: .medium)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: AppColors.textDim,
            ]
            let textSize = fileSize.size(withAttributes: attrs)
            let textX = (previewSize.width - textSize.width) / 2
            let textY: CGFloat = (previewSize.height / 2) - 28
            fileSize.draw(at: NSPoint(x: textX, y: textY), withAttributes: attrs)
        }

        image.unlockFocus()
        return image
    }
}
