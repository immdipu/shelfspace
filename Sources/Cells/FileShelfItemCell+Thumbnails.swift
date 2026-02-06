import Cocoa

// MARK: - Thumbnail Loading (legacy compatibility)
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

    func createTextPreviewImage(text: String) -> NSImage {
        let size = NSSize(width: 160, height: 120)
        let image = NSImage(size: size)
        image.lockFocus()
        AppColors.previewBackground.setFill()
        NSRect(origin: .zero, size: size).fill()
        let truncatedText = String(text.prefix(200))
        let font = NSFont.monospacedSystemFont(ofSize: 9, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: AppColors.previewText,
        ]
        let textRect = NSRect(x: 8, y: 8, width: size.width - 16, height: size.height - 16)
        truncatedText.draw(in: textRect, withAttributes: attributes)
        image.unlockFocus()
        return image
    }
}
