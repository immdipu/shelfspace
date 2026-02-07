import Cocoa
import UniformTypeIdentifiers

class ClipboardMonitor {
    private var timer: Timer?
    private var lastChangeCount: Int = 0
    private let onNewItems: ([FileShelfItem]) -> Void
    private let tempDirectory: URL
    private var ignoringClipboardUntil: Date?

    init(onNewItems: @escaping ([FileShelfItem]) -> Void) {
        self.onNewItems = onNewItems

        // Create temp directory for clipboard items
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("FileShelf")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        self.tempDirectory = tempDir

        self.lastChangeCount = NSPasteboard.general.changeCount
    }

    func start() {
        stop()
        let interval = SettingsStore.shared.pollingInterval
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }

        NotificationCenter.default.addObserver(self, selector: #selector(pollingIntervalChanged), name: .settingsPollingIntervalChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(monitoringChanged), name: .settingsClipboardMonitoringChanged, object: nil)
    }

    func stop() {
        timer?.invalidate()
        timer = nil
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func pollingIntervalChanged() {
        guard timer != nil else { return }
        stop()
        start()
    }

    @objc private func monitoringChanged() {
        if SettingsStore.shared.clipboardMonitoringEnabled {
            if timer == nil { start() }
        } else {
            timer?.invalidate()
            timer = nil
        }
    }

    func ignoreNextClipboardChange() {
        ignoringClipboardUntil = Date().addingTimeInterval(2.0)
        Logger.debug("Ignoring clipboard changes for 2 seconds", category: .clipboard)
    }

    private func checkClipboard() {
        let pasteboard = NSPasteboard.general

        guard pasteboard.changeCount != lastChangeCount else { return }

        if let ignoreUntil = ignoringClipboardUntil, Date() < ignoreUntil {
            lastChangeCount = pasteboard.changeCount
            return
        }

        if let ignoreUntil = ignoringClipboardUntil, Date() >= ignoreUntil {
            ignoringClipboardUntil = nil
        }

        lastChangeCount = pasteboard.changeCount

        let settings = SettingsStore.shared
        var newItems: [FileShelfItem] = []

        // Strategy: Only process ONE type of content per clipboard change
        // Priority: Files > Images > Text

        // Check for file URLs first (highest priority)
        if settings.captureFiles, let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            let fileURLs = urls.filter { $0.isFileURL }
            if !fileURLs.isEmpty {
                for url in fileURLs {
                    if let item = createItemFromURL(url) {
                        newItems.append(item)
                    }
                }
            }
        }

        // Check for images (second priority) - only if no files were found
        if newItems.isEmpty && settings.captureImages {
            if let images = pasteboard.readObjects(forClasses: [NSImage.self]) as? [NSImage] {
                if !images.isEmpty {
                    for (index, image) in images.enumerated() {
                        if let item = createItemFromImage(image, index: index) {
                            newItems.append(item)
                        }
                    }
                }
            }
        }

        // Check for text (lowest priority) - only if no files or images were found
        if newItems.isEmpty && settings.captureText {
            let maxLen = settings.maxTextLength
            if let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
                for string in strings {
                    // Check if it's a file path
                    let url = URL(fileURLWithPath: string)
                    if FileManager.default.fileExists(atPath: url.path) {
                        if settings.captureFiles, let item = createItemFromURL(url) {
                            newItems.append(item)
                        }
                    } else if string.count > 3 && string.count < maxLen {
                        // It's regular text content
                        let textItem = FileShelfItem(textContent: string, origin: .clipboard)
                        newItems.append(textItem)
                    }
                }
            }
        }

        if !newItems.isEmpty {
            Logger.debug("Found \(newItems.count) new clipboard items", category: .clipboard)
            onNewItems(newItems)
        }
    }

    private func createItemFromImage(_ image: NSImage, index: Int) -> FileShelfItem? {
        // Determine if this is likely a screenshot
        let isScreenshot = isLikelyScreenshot(image)
        let origin: FileShelfItem.ItemOrigin = isScreenshot ? .screenshot : .clipboard

        // Generate filename
        let timestamp = Int(Date().timeIntervalSince1970)
        let filename = isScreenshot ? "Screenshot_\(timestamp)_\(index).png" : "Image_\(timestamp)_\(index).png"
        let tempURL = tempDirectory.appendingPathComponent(filename)

        // Save image to temp file
        guard let data = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: data),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            return nil
        }

        do {
            try pngData.write(to: tempURL)
            let fileSize = Int64(pngData.count)
            return FileShelfItem(originalName: filename, fileURL: tempURL, mimeType: "image/png", fileSize: fileSize, origin: origin)
        } catch {
            Logger.error("Failed to save image: \(error)", category: .clipboard)
            return nil
        }
    }

    private func createItemFromURL(_ url: URL) -> FileShelfItem? {
        guard url.isFileURL else { return nil }

        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }

        // Get file attributes
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0

            // Check file size limit from settings
            let maxFileSize: Int64 = Int64(SettingsStore.shared.maxFileSizeMB) * 1024 * 1024
            guard fileSize <= maxFileSize else {
                Logger.warning("File too large: \(fileSize) bytes (max: \(maxFileSize))", category: .clipboard)
                return nil
            }

            // Determine MIME type
            let mimeType = url.mimeType

            // Copy file to temp directory if it's not already there
            let tempURL: URL
            if url.path.hasPrefix(tempDirectory.path) {
                tempURL = url
            } else {
                let filename = url.lastPathComponent
                tempURL = tempDirectory.appendingPathComponent(filename)
                try FileManager.default.copyItem(at: url, to: tempURL)
            }

            return FileShelfItem(originalName: url.lastPathComponent, fileURL: tempURL, mimeType: mimeType, fileSize: fileSize, origin: .clipboard)
        } catch {
            Logger.error("Failed to process file: \(error)", category: .clipboard)
            return nil
        }
    }

    private func isLikelyScreenshot(_ image: NSImage) -> Bool {
        // Heuristics to determine if an image is likely a screenshot
        let size = image.size

        // Check for common screen resolutions
        let commonScreenWidths: [CGFloat] = [1280, 1440, 1920, 2560, 3840]
        let isCommonWidth = commonScreenWidths.contains { abs($0 - size.width) < 50 }

        // Screenshots are often larger than typical web images
        let isLargeEnough = size.width > 800 && size.height > 600

        return isCommonWidth || isLargeEnough
    }
}

extension URL {
    var mimeType: String {
        if let utType = UTType(filenameExtension: self.pathExtension) {
            if let mimeType = utType.preferredMIMEType {
                return mimeType
            }
        }
        return "application/octet-stream"
    }
}
