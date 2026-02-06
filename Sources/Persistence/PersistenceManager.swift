import Foundation

/// Manages persistence of shelf items to disk
final class PersistenceManager {
    static let shared = PersistenceManager()

    /// Application Support directory for ShelfSpace
    private let appSupportDirectory: URL

    /// Directory for persisted files
    private let filesDirectory: URL

    /// Path to items.json
    private let itemsFilePath: URL

    /// Debounce timer for auto-save
    private var saveTimer: Timer?

    /// Debounce delay in seconds
    private let saveDebounceDelay: TimeInterval = 1.0

    private init() {
        // Create Application Support directory
        let fileManager = FileManager.default
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        appSupportDirectory = appSupport.appendingPathComponent("ShelfSpace")
        filesDirectory = appSupportDirectory.appendingPathComponent("Files")
        itemsFilePath = appSupportDirectory.appendingPathComponent("items.json")

        // Create directories if needed
        createDirectoriesIfNeeded()
    }

    private func createDirectoriesIfNeeded() {
        let fileManager = FileManager.default

        for directory in [appSupportDirectory, filesDirectory] {
            if !fileManager.fileExists(atPath: directory.path) {
                do {
                    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                    Logger.debug("Created directory: \(directory.path)", category: .persistence)
                } catch {
                    Logger.error("Failed to create directory: \(error)", category: .persistence)
                }
            }
        }
    }

    // MARK: - Save Items

    /// Save items with debouncing (call this frequently, actual save happens after delay)
    func saveItemsDebounced(_ items: [FileShelfItem]) {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: saveDebounceDelay, repeats: false) { [weak self] _ in
            self?.saveItems(items)
        }
    }

    /// Save items immediately
    func saveItems(_ items: [FileShelfItem]) {
        // First, copy files to persistent storage
        var persistedItems: [FileShelfItem] = []

        for item in items {
            if let persistedItem = copyToPersistentStorage(item) {
                persistedItems.append(persistedItem)
            } else {
                // Keep item even if file copy fails (for text items without files)
                persistedItems.append(item)
            }
        }

        // Save items metadata to JSON
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(persistedItems)
            try data.write(to: itemsFilePath)
            Logger.debug("Saved \(persistedItems.count) items to disk", category: .persistence)
        } catch {
            Logger.error("Failed to save items: \(error)", category: .persistence)
        }
    }

    // MARK: - Load Items

    /// Load items from disk
    func loadItems() -> [FileShelfItem] {
        guard FileManager.default.fileExists(atPath: itemsFilePath.path) else {
            Logger.debug("No saved items found", category: .persistence)
            return []
        }

        do {
            let data = try Data(contentsOf: itemsFilePath)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            var items = try decoder.decode([FileShelfItem].self, from: data)

            // Validate that files still exist
            items = items.filter { item in
                if let fileURL = item.fileURL {
                    let exists = FileManager.default.fileExists(atPath: fileURL.path)
                    if !exists {
                        Logger.warning("File no longer exists: \(fileURL.path)", category: .persistence)
                    }
                    return exists || item.isText // Keep text items even without files
                }
                return true // Keep items without file URLs (text items)
            }

            Logger.debug("Loaded \(items.count) items from disk", category: .persistence)
            return items
        } catch {
            Logger.error("Failed to load items: \(error)", category: .persistence)
            return []
        }
    }

    // MARK: - File Management

    /// Copy item's file to persistent storage
    private func copyToPersistentStorage(_ item: FileShelfItem) -> FileShelfItem? {
        guard let sourceURL = item.fileURL else {
            // Text items don't have files, return as-is
            return item
        }

        // Check if file is already in persistent storage
        if sourceURL.path.hasPrefix(filesDirectory.path) {
            return item
        }

        // Generate destination URL
        let filename = sourceURL.lastPathComponent
        var destURL = filesDirectory.appendingPathComponent(filename)

        // Generate unique filename if needed
        var counter = 1
        while FileManager.default.fileExists(atPath: destURL.path) {
            let name = sourceURL.deletingPathExtension().lastPathComponent
            let ext = sourceURL.pathExtension
            let newName = ext.isEmpty ? "\(name)_\(counter)" : "\(name)_\(counter).\(ext)"
            destURL = filesDirectory.appendingPathComponent(newName)
            counter += 1
        }

        do {
            try FileManager.default.copyItem(at: sourceURL, to: destURL)

            // Create new item with updated file URL
            let persistedItem = FileShelfItem(
                originalName: item.originalName,
                fileURL: destURL,
                mimeType: item.mimeType,
                fileSize: item.fileSize,
                origin: item.origin,
                textContent: item.textContent,
                id: item.id,
                dateAdded: item.dateAdded,
                isPinned: item.isPinned
            )

            Logger.debug("Copied file to persistent storage: \(destURL.lastPathComponent)", category: .persistence)
            return persistedItem
        } catch {
            Logger.error("Failed to copy file to persistent storage: \(error)", category: .persistence)
            return nil
        }
    }

    /// Delete a file from persistent storage
    func deleteFile(for item: FileShelfItem) {
        guard let fileURL = item.fileURL,
              fileURL.path.hasPrefix(filesDirectory.path) else {
            return
        }

        do {
            try FileManager.default.removeItem(at: fileURL)
            Logger.debug("Deleted file from persistent storage: \(fileURL.lastPathComponent)", category: .persistence)
        } catch {
            Logger.error("Failed to delete file: \(error)", category: .persistence)
        }
    }

    /// Clean up orphaned files (files in storage that aren't referenced by any item)
    func cleanupOrphanedFiles(knownItems: [FileShelfItem]) {
        let fileManager = FileManager.default
        guard let contents = try? fileManager.contentsOfDirectory(at: filesDirectory, includingPropertiesForKeys: nil) else {
            return
        }

        let knownPaths = Set(knownItems.compactMap { $0.fileURL?.path })

        for fileURL in contents {
            if !knownPaths.contains(fileURL.path) {
                do {
                    try fileManager.removeItem(at: fileURL)
                    Logger.debug("Cleaned up orphaned file: \(fileURL.lastPathComponent)", category: .persistence)
                } catch {
                    Logger.error("Failed to clean up orphaned file: \(error)", category: .persistence)
                }
            }
        }
    }
}
