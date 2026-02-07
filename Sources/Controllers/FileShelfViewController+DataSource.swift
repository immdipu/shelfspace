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

        // Force loadView() so all subviews exist before we configure them.
        // Without this, configure() sets properties that setupGridViews() overwrites.
        _ = cell.view

        cell.applyViewMode(GridDensityManager.shared.currentViewMode)
        cell.configure(with: item, delegate: self)

        return cell
    }
}
