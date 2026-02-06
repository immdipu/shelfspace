import Cocoa

// MARK: - Collection View Delegate
extension FileShelfViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        return true
    }

    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        session.animatesToStartingPositionsOnCancelOrFail = true

        var draggingItems: [NSDraggingItem] = []
        for indexPath in indexPaths {
            let item = filteredItems[indexPath.item]
            if let draggingItem = item.createDraggingItem() {
                draggingItems.append(draggingItem)
            }
        }

        session.enumerateDraggingItems(options: [], for: nil, classes: [NSPasteboardItem.self], searchOptions: [:]) { (draggingItem, idx, stop) in
            if idx < draggingItems.count {
                draggingItem.setDraggingFrame(draggingItems[idx].draggingFrame, contents: draggingItems[idx].item)
            }
        }
    }

    // MARK: - Drop Handling
    func collectionView(_ collectionView: NSCollectionView, validateDrop draggingInfo: any NSDraggingInfo, proposedIndex proposedDropIndex: UnsafeMutablePointer<Int>, dropOperation proposedDropOperation: UnsafeMutablePointer<NSCollectionView.DropOperation>) -> NSDragOperation {
        if canAcceptDrag(draggingInfo) {
            showDragOverlay(true)
            proposedDropOperation.pointee = .on
            return .copy
        }
        return []
    }

    func collectionView(_ collectionView: NSCollectionView, acceptDrop draggingInfo: NSDraggingInfo, index: Int, dropOperation: NSCollectionView.DropOperation) -> Bool {
        showDragOverlay(false)
        return handleDropOperation(draggingInfo)
    }

    func collectionView(_ collectionView: NSCollectionView, draggingExited sender: NSDraggingInfo?) {
        showDragOverlay(false)
    }
}
