import Foundation

/// Centralized temp directory management
final class TempDirectoryManager {
    static let shared = TempDirectoryManager()

    /// Main temp directory for the app
    let appTempDirectory: URL

    /// Directory for clipboard items
    let clipboardTempDirectory: URL

    /// Directory for dropped files
    let droppedFilesTempDirectory: URL

    private init() {
        let base = FileManager.default.temporaryDirectory.appendingPathComponent("ShelfSpace")
        self.appTempDirectory = base
        self.clipboardTempDirectory = base.appendingPathComponent("Clipboard")
        self.droppedFilesTempDirectory = base.appendingPathComponent("Dropped")

        createDirectoriesIfNeeded()
    }

    private func createDirectoriesIfNeeded() {
        let fileManager = FileManager.default

        for directory in [appTempDirectory, clipboardTempDirectory, droppedFilesTempDirectory] {
            if !fileManager.fileExists(atPath: directory.path) {
                do {
                    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                } catch {
                    Logger.error("Failed to create temp directory: \(error)", category: .general)
                }
            }
        }
    }

    /// Generate a unique filename in the specified directory
    func uniqueURL(for filename: String, in directory: URL) -> URL {
        var finalURL = directory.appendingPathComponent(filename)
        var counter = 1

        while FileManager.default.fileExists(atPath: finalURL.path) {
            let name = URL(fileURLWithPath: filename).deletingPathExtension().lastPathComponent
            let ext = URL(fileURLWithPath: filename).pathExtension
            let newName = ext.isEmpty ? "\(name)_\(counter)" : "\(name)_\(counter).\(ext)"
            finalURL = directory.appendingPathComponent(newName)
            counter += 1
        }

        return finalURL
    }

    /// Clean up all temp files
    func cleanup() {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: appTempDirectory)
            createDirectoriesIfNeeded()
        } catch {
            Logger.error("Failed to cleanup temp directory: \(error)", category: .general)
        }
    }
}
