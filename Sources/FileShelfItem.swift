import Foundation
import UniformTypeIdentifiers
import Cocoa

class FileShelfItem: ObservableObject, Identifiable {
    let id = UUID()
    let originalName: String
    let fileURL: URL?
    let mimeType: String
    let fileSize: Int64
    let dateAdded: Date
    let origin: ItemOrigin
    var isPinned: Bool = false
    let textContent: String?
    let itemType: ItemType
    
    enum ItemOrigin {
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
    
    enum ItemType {
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
    
    init(originalName: String, fileURL: URL?, mimeType: String, fileSize: Int64, origin: ItemOrigin, textContent: String? = nil) {
        self.originalName = originalName
        self.fileURL = fileURL
        self.mimeType = mimeType
        self.fileSize = fileSize
        self.dateAdded = Date()
        self.origin = origin
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
            
            // Use text icon
            let icon = NSImage(systemSymbolName: "doc.text", accessibilityDescription: "Text")!
            icon.size = NSSize(width: 64, height: 64)
            draggingItem.setDraggingFrame(NSRect(origin: .zero, size: icon.size), contents: icon)
            return draggingItem
        } else if let fileURL = fileURL {
            let draggingItem = NSDraggingItem(pasteboardWriter: fileURL as NSURL)
            
            // Set drag image
            if isImage, let image = NSImage(contentsOf: fileURL) {
                let dragImage = image.copy() as! NSImage
                dragImage.size = NSSize(width: 64, height: 64)
                draggingItem.setDraggingFrame(NSRect(origin: .zero, size: dragImage.size), contents: dragImage)
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