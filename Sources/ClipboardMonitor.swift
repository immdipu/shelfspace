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
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkClipboard()
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    func ignoreNextClipboardChange() {
        ignoringClipboardUntil = Date().addingTimeInterval(2.0)
        print("ClipboardMonitor: Ignoring clipboard changes for 2 seconds")
    }
    
    private func checkClipboard() {
        let pasteboard = NSPasteboard.general
        
        guard pasteboard.changeCount != lastChangeCount else { return }
        
        if let ignoreUntil = ignoringClipboardUntil, Date() < ignoreUntil {
            print("ClipboardMonitor: Ignoring clipboard change (self-initiated)")
            lastChangeCount = pasteboard.changeCount
            return
        }
        
        if let ignoreUntil = ignoringClipboardUntil, Date() >= ignoreUntil {
            ignoringClipboardUntil = nil
            print("ClipboardMonitor: Resumed monitoring clipboard changes")
        }
        
        lastChangeCount = pasteboard.changeCount
        
        var newItems: [FileShelfItem] = []
        
        // Strategy: Only process ONE type of content per clipboard change
        // Priority: Files > Images > Text
        
        // Check for file URLs first (highest priority)
        if let urls = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            let fileURLs = urls.filter { $0.isFileURL }
            if !fileURLs.isEmpty {
                print("ClipboardMonitor: Found file URLs, processing only files")
                for url in fileURLs {
                    if let item = createItemFromURL(url) {
                        newItems.append(item)
                    }
                }
            }
        }
        
        // Check for images (second priority) - only if no files were found
        if newItems.isEmpty {
            if let images = pasteboard.readObjects(forClasses: [NSImage.self]) as? [NSImage] {
                if !images.isEmpty {
                    print("ClipboardMonitor: Found images, processing only images")
                    for (index, image) in images.enumerated() {
                        if let item = createItemFromImage(image, index: index) {
                            newItems.append(item)
                        }
                    }
                }
            }
        }
        
        // Check for text (lowest priority) - only if no files or images were found
        if newItems.isEmpty {
            if let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
                print("ClipboardMonitor: Found text, processing text content")
                for string in strings {
                    // Check if it's a file path
                    let url = URL(fileURLWithPath: string)
                    if FileManager.default.fileExists(atPath: url.path) {
                        if let item = createItemFromURL(url) {
                            newItems.append(item)
                        }
                    } else if string.count > 3 && string.count < 10000 { // Reasonable text length
                        // It's regular text content
                        let textItem = FileShelfItem(textContent: string, origin: .clipboard)
                        newItems.append(textItem)
                    }
                }
            }
        }
        
        if !newItems.isEmpty {
            print("ClipboardMonitor: Found \(newItems.count) new items")
            for item in newItems {
                print("  - \(item.itemType): \(item.displayName)")
                if item.isText, let content = item.textContent {
                    print("    Content preview: \(String(content.prefix(50)))...")
                }
            }
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
            print("Failed to save image: \(error)")
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
            
            // Check file size limit (200 MB)
            let maxFileSize: Int64 = 200 * 1024 * 1024 // 200 MB in bytes
            guard fileSize <= maxFileSize else {
                print("File too large: \(fileSize) bytes (max: \(maxFileSize))")
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
            print("Failed to process file: \(error)")
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