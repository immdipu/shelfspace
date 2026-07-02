import Foundation
import UniformTypeIdentifiers
import Cocoa

class FileShelfItem: ObservableObject, Identifiable, Codable {
    let id: UUID
    let originalName: String
    var fileURL: URL?
    let mimeType: String
    let fileSize: Int64
    let dateAdded: Date
    let origin: ItemOrigin
    var isPinned: Bool = false
    let textContent: String?
    let itemType: ItemType

    enum ItemOrigin: String, Codable {
        case dragDrop
        case clipboard
        case screenshot

        var displayName: String {
            switch self {
            case .dragDrop: return "Dropped"
            case .clipboard: return "Copied"
            case .screenshot: return "Screenshot"
            }
        }
    }

    enum ItemType: String, Codable {
        case image
        case text
        case document
        case archive
        case video
        case audio
        case other

        var displayName: String {
            switch self {
            case .image: return "Image"
            case .text: return "Text"
            case .document: return "Document"
            case .archive: return "Archive"
            case .video: return "Video"
            case .audio: return "Audio"
            case .other: return "File"
            }
        }

        var iconName: String {
            switch self {
            case .image: return "photo"
            case .text: return "doc.text"
            case .document: return "doc"
            case .archive: return "archivebox"
            case .video: return "video"
            case .audio: return "music.note"
            case .other: return "doc.circle"
            }
        }
    }

    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, originalName, fileURLPath, mimeType, fileSize, dateAdded, origin, isPinned, textContent, itemType
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        originalName = try container.decode(String.self, forKey: .originalName)
        if let path = try container.decodeIfPresent(String.self, forKey: .fileURLPath) {
            fileURL = URL(fileURLWithPath: path)
        } else {
            fileURL = nil
        }
        mimeType = try container.decode(String.self, forKey: .mimeType)
        fileSize = try container.decode(Int64.self, forKey: .fileSize)
        dateAdded = try container.decode(Date.self, forKey: .dateAdded)
        origin = try container.decode(ItemOrigin.self, forKey: .origin)
        isPinned = try container.decode(Bool.self, forKey: .isPinned)
        textContent = try container.decodeIfPresent(String.self, forKey: .textContent)
        itemType = try container.decode(ItemType.self, forKey: .itemType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(originalName, forKey: .originalName)
        try container.encodeIfPresent(fileURL?.path, forKey: .fileURLPath)
        try container.encode(mimeType, forKey: .mimeType)
        try container.encode(fileSize, forKey: .fileSize)
        try container.encode(dateAdded, forKey: .dateAdded)
        try container.encode(origin, forKey: .origin)
        try container.encode(isPinned, forKey: .isPinned)
        try container.encodeIfPresent(textContent, forKey: .textContent)
        try container.encode(itemType, forKey: .itemType)
    }

    // MARK: - Initialization
    init(originalName: String, fileURL: URL?, mimeType: String, fileSize: Int64, origin: ItemOrigin, textContent: String? = nil, id: UUID = UUID(), dateAdded: Date = Date(), isPinned: Bool = false) {
        self.id = id
        self.originalName = originalName
        self.fileURL = fileURL
        self.mimeType = mimeType
        self.fileSize = fileSize
        self.dateAdded = dateAdded
        self.origin = origin
        self.isPinned = isPinned
        self.textContent = textContent

        // Determine item type based on MIME type and content
        if textContent != nil {
            self.itemType = .text
        } else if mimeType.hasPrefix("image/") {
            self.itemType = .image
        } else if mimeType.hasPrefix("video/") {
            self.itemType = .video
        } else if mimeType.hasPrefix("audio/") {
            self.itemType = .audio
        } else if mimeType.contains("zip") || mimeType.contains("archive") || mimeType.contains("tar") || mimeType.contains("rar") {
            self.itemType = .archive
        } else if mimeType.contains("pdf") || mimeType.contains("doc") || mimeType.contains("text") {
            self.itemType = .document
        } else {
            self.itemType = .other
        }
    }

    // Convenience initializer for text content
    convenience init(textContent: String, origin: ItemOrigin) {
        self.init(
            originalName: "Text Clip",
            fileURL: nil,
            mimeType: "text/plain",
            fileSize: Int64(textContent.utf8.count),
            origin: origin,
            textContent: textContent
        )
    }

    var isImage: Bool {
        return itemType == .image
    }

    var isText: Bool {
        return itemType == .text
    }

    /// File on disk whose contents can be shown as text (dropped .txt/.md/.swift etc)
    var isTextReadableFile: Bool {
        guard let fileURL = fileURL else { return false }
        if mimeType.lowercased().hasPrefix("text/") { return true }
        let textExtensions: Set<String> = [
            "txt", "md", "markdown", "rtf", "json", "xml", "csv", "tsv",
            "yaml", "yml", "log", "ini", "conf", "cfg", "toml",
            "html", "css", "js", "ts", "swift", "py", "rb", "java", "kt",
            "c", "cc", "cpp", "h", "hpp", "m", "mm", "sh", "zsh", "bash"
        ]
        return textExtensions.contains(fileURL.pathExtension.lowercased())
    }

    /// Whether the preview overlay can show this item
    var isPreviewable: Bool {
        return isImage || isText || isTextReadableFile
    }

    /// Content that looks like code gets a monospaced preview font
    var looksLikeCode: Bool {
        if let fileURL = fileURL {
            let codeExtensions: Set<String> = [
                "json", "xml", "yaml", "yml", "toml", "ini", "conf", "cfg",
                "html", "css", "js", "ts", "swift", "py", "rb", "java", "kt",
                "c", "cc", "cpp", "h", "hpp", "m", "mm", "sh", "zsh", "bash"
            ]
            if codeExtensions.contains(fileURL.pathExtension.lowercased()) { return true }
        }
        guard let text = textContent else { return false }
        let codeMarkers = ["{", "};", "func ", "def ", "import ", "const ", "let ", "var ", "</", "#!"]
        return codeMarkers.contains { text.contains($0) }
    }

    var displayName: String {
        return originalName.isEmpty ? "Untitled" : originalName
    }

    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }

    var fileExtension: String {
        return URL(fileURLWithPath: originalName).pathExtension.lowercased()
    }

    // Copy file data to clipboard
    func copyToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        if isText, let text = textContent {
            pasteboard.setString(text, forType: .string)
        } else if isImage, let fileURL = fileURL, let image = NSImage(contentsOf: fileURL) {
            pasteboard.writeObjects([image])
        } else if let fileURL = fileURL {
            pasteboard.setString(fileURL.path, forType: NSPasteboard.PasteboardType.fileURL)
        }
    }

    // Create dragging item for drag operations
    func createDraggingItem() -> NSDraggingItem? {
        if isText, let text = textContent {
            // Create pasteboard item for text
            let pasteboardItem = NSPasteboardItem()
            pasteboardItem.setString(text, forType: .string)
            let draggingItem = NSDraggingItem(pasteboardWriter: pasteboardItem)

            // Use text icon - safe unwrap
            if let icon = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Text") {
                icon.size = NSSize(width: 64, height: 64)
                draggingItem.setDraggingFrame(NSRect(origin: .zero, size: icon.size), contents: icon)
            } else {
                let fallbackIcon = NSWorkspace.shared.icon(forFile: "")
                fallbackIcon.size = NSSize(width: 64, height: 64)
                draggingItem.setDraggingFrame(NSRect(origin: .zero, size: fallbackIcon.size), contents: fallbackIcon)
            }
            return draggingItem
        } else if let fileURL = fileURL {
            let draggingItem = NSDraggingItem(pasteboardWriter: fileURL as NSURL)

            // Set drag image
            if isImage, let image = NSImage(contentsOf: fileURL) {
                // Safe cast for copied image
                if let dragImage = image.copy() as? NSImage {
                    dragImage.size = NSSize(width: 64, height: 64)
                    draggingItem.setDraggingFrame(NSRect(origin: .zero, size: dragImage.size), contents: dragImage)
                } else {
                    // Fallback to original image
                    let resizedImage = NSImage(size: NSSize(width: 64, height: 64))
                    resizedImage.lockFocus()
                    image.draw(in: NSRect(origin: .zero, size: NSSize(width: 64, height: 64)))
                    resizedImage.unlockFocus()
                    draggingItem.setDraggingFrame(NSRect(origin: .zero, size: resizedImage.size), contents: resizedImage)
                }
            } else {
                // Use file icon for non-images
                let icon = NSWorkspace.shared.icon(forFile: fileURL.path)
                icon.size = NSSize(width: 64, height: 64)
                draggingItem.setDraggingFrame(NSRect(origin: .zero, size: icon.size), contents: icon)
            }
            return draggingItem
        }
        return nil
    }

    // Clean up temporary file
    func cleanup() {
        if let fileURL = fileURL {
            try? FileManager.default.removeItem(at: fileURL)
        }
    }
}
