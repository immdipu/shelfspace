import Cocoa

// MARK: - Preview Overlay
extension FileShelfViewController: PreviewOverlayViewDelegate {
    func showPreview(for item: FileShelfItem) {
        guard item.isPreviewable else { return }
        previewOverlay?.removeFromSuperview()

        let overlay = PreviewOverlayView()
        overlay.delegate = self

        // Seed with the cell's already-loaded thumbnail so the overlay paints
        // instantly; full resolution is swapped in asynchronously.
        var initialImage: NSImage?
        if item.isImage {
            initialImage = visibleCell(for: item)?.thumbnailImageView.image
        }
        overlay.configure(with: item, initialImage: initialImage)
        overlay.present(in: view)
        previewOverlay = overlay
    }

    func closePreview() {
        previewOverlay?.dismiss { [weak self] in
            guard let self = self else { return }
            self.view.window?.makeFirstResponder(self.collectionView)
        }
        previewOverlay = nil
    }

    // MARK: PreviewOverlayViewDelegate

    func previewOverlayDidRequestClose(_ overlay: PreviewOverlayView) {
        closePreview()
    }

    func previewOverlay(_ overlay: PreviewOverlayView, didRequestCopyItem item: FileShelfItem) {
        copyItem(item)
    }

    func previewOverlay(_ overlay: PreviewOverlayView, didTogglePinItem item: FileShelfItem) {
        togglePin(item)
        overlay.updatePinState()
    }

    func previewOverlay(_ overlay: PreviewOverlayView, didRequestDeleteItem item: FileShelfItem) {
        removeItem(item)
    }
}
