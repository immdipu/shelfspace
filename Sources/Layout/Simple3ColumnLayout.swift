import Cocoa

/// Custom 3-column layout for the collection view
class Simple3ColumnLayout: NSCollectionViewLayout {
    private let itemSize = NSSize(width: 120, height: 140)
    private let itemsPerRow = 3
    private let verticalSpacing: CGFloat = 16
    private let topBottomMargin: CGFloat = 16

    private var itemAttributes: [NSCollectionViewLayoutAttributes] = []
    private var contentSize = NSSize.zero

    override func prepare() {
        super.prepare()

        guard let collectionView = collectionView else { return }

        itemAttributes.removeAll()

        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        if numberOfItems == 0 {
            contentSize = NSSize.zero
            return
        }

        // Calculate horizontal spacing for exactly 3 items per row
        let availableWidth = collectionView.bounds.width
        let totalItemWidth = CGFloat(itemsPerRow) * itemSize.width  // 3 * 120 = 360
        let remainingSpace = availableWidth - totalItemWidth
        let horizontalSpacing = remainingSpace / 4  // left + gap1 + gap2 + right

        Logger.debug("3-Column Layout: availableWidth=\(availableWidth), horizontalSpacing=\(horizontalSpacing)", category: .layout)

        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)

            let row = item / itemsPerRow
            let col = item % itemsPerRow

            let x = horizontalSpacing + CGFloat(col) * (itemSize.width + horizontalSpacing)
            let y = topBottomMargin + CGFloat(row) * (itemSize.height + verticalSpacing)

            attributes.frame = NSRect(
                x: x,
                y: y,
                width: itemSize.width,
                height: itemSize.height
            )

            itemAttributes.append(attributes)
        }

        let numberOfRows = (numberOfItems + itemsPerRow - 1) / itemsPerRow
        contentSize = NSSize(
            width: collectionView.bounds.width,
            height: topBottomMargin + CGFloat(numberOfRows) * itemSize.height + CGFloat(max(0, numberOfRows - 1)) * verticalSpacing + topBottomMargin
        )
    }

    override var collectionViewContentSize: NSSize {
        return contentSize
    }

    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return itemAttributes.filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        guard indexPath.item < itemAttributes.count else { return nil }
        return itemAttributes[indexPath.item]
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width
    }
}
