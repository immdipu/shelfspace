import Cocoa
import QuickLookThumbnailing

// MARK: - Thumbnail & Preview Image Generation
extension FileShelfItemCell {
    static let quickLookCache = NSCache<NSString, NSImage>()

    /// Renders a color swatch with the hex value for color clips
    func createColorPreviewImage(color: NSColor, hex: String, size: NSSize? = nil) -> NSImage {
        let previewSize = size ?? NSSize(width: max(previewArea.bounds.width, 200), height: max(previewArea.bounds.height, 100))
        let image = NSImage(size: previewSize)
        image.lockFocus()

        color.setFill()
        NSRect(origin: .zero, size: previewSize).fill()

        // Hex label on a pill that stays readable on any swatch color
        let font = NSFont.monospacedSystemFont(ofSize: 11, weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.white]
        let text = hex.uppercased()
        let textSize = text.size(withAttributes: attrs)
        let padding: CGFloat = 6
        let pillRect = NSRect(
            x: (previewSize.width - textSize.width) / 2 - padding,
            y: 8,
            width: textSize.width + padding * 2,
            height: textSize.height + 6
        )
        NSColor.black.withAlphaComponent(0.45).setFill()
        NSBezierPath(roundedRect: pillRect, xRadius: pillRect.height / 2, yRadius: pillRect.height / 2).fill()
        text.draw(at: NSPoint(x: pillRect.minX + padding, y: pillRect.minY + 3), withAttributes: attrs)

        image.unlockFocus()
        return image
    }

    /// Upgrades the grid file placeholder to a real QuickLook thumbnail (PDF page, video frame, …)
    func loadQuickLookGridThumbnail(for item: FileShelfItem) {
        let cacheKey = "grid-\(item.id.uuidString)" as NSString
        if let cached = Self.quickLookCache.object(forKey: cacheKey) {
            applyQuickLookGridImage(cached)
            return
        }
        let size = NSSize(width: max(previewArea.bounds.width, 200), height: max(previewArea.bounds.height, 100))
        let token = UUID()
        thumbnailLoadToken = token
        generateQuickLookThumbnail(for: item, size: size) { [weak self] image in
            guard let self = self,
                  self.thumbnailLoadToken == token,
                  self.fileItem?.id == item.id,
                  let image = image else { return }
            Self.quickLookCache.setObject(image, forKey: cacheKey)
            self.applyQuickLookGridImage(image)
        }
    }

    private func applyQuickLookGridImage(_ image: NSImage) {
        thumbnailImageView.layer?.contents = nil
        thumbnailImageView.imageScaling = .scaleProportionallyUpOrDown
        thumbnailImageView.imageAlignment = .alignCenter
        thumbnailImageView.image = image
        thumbnailImageView.isHidden = false
    }

    /// QuickLook thumbnail for the 36x36 list icon
    func loadQuickLookListThumbnail(for item: FileShelfItem) {
        let cacheKey = "list-\(item.id.uuidString)" as NSString
        if let cached = Self.quickLookCache.object(forKey: cacheKey) {
            listIconImageView.image = cached
            listIconImageView.isHidden = false
            listIconView.isHidden = true
            return
        }
        let token = UUID()
        listIconLoadToken = token
        generateQuickLookThumbnail(for: item, size: NSSize(width: 36, height: 36)) { [weak self] image in
            guard let self = self,
                  self.listIconLoadToken == token,
                  self.fileItem?.id == item.id,
                  let image = image else { return }
            Self.quickLookCache.setObject(image, forKey: cacheKey)
            self.listIconImageView.image = image
            self.listIconImageView.isHidden = false
            self.listIconView.isHidden = true
        }
    }

    /// Only real content thumbnails (.thumbnail) — when a file type has none
    /// (zip, unknown binaries) the completion gets nil and the icon stays
    private func generateQuickLookThumbnail(for item: FileShelfItem, size: NSSize, completion: @escaping (NSImage?) -> Void) {
        guard let fileURL = item.fileURL else {
            completion(nil)
            return
        }
        let scale = view.window?.backingScaleFactor ?? 2.0
        let request = QLThumbnailGenerator.Request(
            fileAt: fileURL,
            size: size,
            scale: scale,
            representationTypes: .thumbnail
        )
        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { representation, _ in
            let image = representation.map { NSImage(cgImage: $0.cgImage, size: size) }
            DispatchQueue.main.async { completion(image) }
        }
    }
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
