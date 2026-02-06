import Cocoa

// MARK: - Drag and Drop Support
extension FileShelfViewController {
    /// Handle files dropped from the DropZoneView
    func handleDroppedFiles(_ urls: [URL]) {
        var newItems: [FileShelfItem] = []

        for url in urls {
            if let item = createItemFromDroppedURL(url) {
                newItems.append(item)
            }
        }

        if !newItems.isEmpty {
            addItems(newItems)
        }
    }

    func handleDropOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard
        var urls: [URL] = []

        // Get file URLs
        if let fileURLs = pasteboard.readObjects(forClasses: [NSURL.self]) as? [URL] {
            let validURLs = fileURLs.filter { $0.isFileURL }
            urls.append(contentsOf: validURLs)
        }

        // Handle string paths
        if let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
            for string in strings {
                let url = URL(fileURLWithPath: string)
                if FileManager.default.fileExists(atPath: url.path) {
                    urls.append(url)
                }
            }
        }

        if !urls.isEmpty {
            var newItems: [FileShelfItem] = []

            for url in urls {
                if let item = createItemFromDroppedURL(url) {
                    newItems.append(item)
                }
            }

            if !newItems.isEmpty {
                addItems(newItems)
                return true
            }
        }

        return false
    }

    func canAcceptDrag(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard

        // Check for file URLs
        if pasteboard.availableType(from: [.fileURL, .URL]) != nil {
            return true
        }

        // Check for string paths
        if let strings = pasteboard.readObjects(forClasses: [NSString.self]) as? [String] {
            return strings.contains { FileManager.default.fileExists(atPath: $0) }
        }

        return false
    }

    func showDragOverlay(_ show: Bool) {
        guard let layer = view.layer else { return }

        if show {
            // Enhanced drag feedback with pulsing border and background tint
            layer.backgroundColor = AppColors.primary.withAlphaComponent(0.08).cgColor
            AnimationHelper.addPulsingBorder(to: layer, color: AppColors.primary.cgColor, width: 2)
            headerView?.setStatus("Drop files anywhere!")
        } else {
            // Reset to normal state
            layer.backgroundColor = AppColors.background.cgColor
            AnimationHelper.removePulsingBorder(from: layer)
            layer.borderWidth = 0
            updateStatusLabel()
        }
    }

    func createItemFromDroppedURL(_ url: URL) -> FileShelfItem? {
        guard url.isFileURL else { return nil }

        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0

            // Check file size limit (200 MB)
            let maxFileSize: Int64 = 200 * 1024 * 1024
            guard fileSize <= maxFileSize else {
                // Show size limit warning
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "File Too Large"
                    alert.informativeText = "Files must be smaller than 200 MB. This file is \(ByteCountFormatter().string(fromByteCount: fileSize))."
                    alert.runModal()
                }
                return nil
            }

            let mimeType = url.mimeType

            // Copy file to temp directory
            let filename = url.lastPathComponent
            let tempURL = tempDirectory.appendingPathComponent(filename)

            // Generate unique filename if file already exists
            var finalURL = tempURL
            var counter = 1
            while FileManager.default.fileExists(atPath: finalURL.path) {
                let name = url.deletingPathExtension().lastPathComponent
                let ext = url.pathExtension
                let newName = "\(name)_\(counter).\(ext)"
                finalURL = tempDirectory.appendingPathComponent(newName)
                counter += 1
            }

            try FileManager.default.copyItem(at: url, to: finalURL)

            return FileShelfItem(originalName: filename, fileURL: finalURL, mimeType: mimeType, fileSize: fileSize, origin: .dragDrop)
        } catch {
            Logger.error("Failed to process dropped file: \(error)", category: .dragDrop)
            return nil
        }
    }
}
