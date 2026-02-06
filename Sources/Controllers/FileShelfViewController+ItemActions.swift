import Cocoa

// MARK: - File Shelf Item Cell Delegate
extension FileShelfViewController: FileShelfItemCellDelegate {
    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestCopyItem item: FileShelfItem) {
        // Tell clipboard monitor to ignore the next change since we're copying
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            appDelegate.clipboardMonitor.ignoreNextClipboardChange()
        }

        item.copyToClipboard()

        // Show brief feedback
        headerView?.setStatus("Copied to clipboard!")
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.updateStatusLabel()
        }
    }

    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestDeleteItem item: FileShelfItem) {
        removeItem(item)
    }

    func fileShelfItemCell(_ cell: FileShelfItemCell, didTogglePinItem item: FileShelfItem) {
        item.isPinned.toggle()

        // Save pin state change (debounced)
        PersistenceManager.shared.saveItemsDebounced(items)

        updateContent()
    }
}
