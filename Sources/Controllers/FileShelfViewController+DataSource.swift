import Cocoa

// MARK: - Collection View Data Source
extension FileShelfViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredItems.count
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let cell = FileShelfItemCell()
        let item = filteredItems[indexPath.item]

        // Apply current view mode before configuring
        cell.applyViewMode(GridDensityManager.shared.currentViewMode)
        cell.configure(with: item, delegate: self)

        return cell
    }
}
