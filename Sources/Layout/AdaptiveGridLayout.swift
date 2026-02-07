import Cocoa

extension Notification.Name {
    static let gridDensityChanged = Notification.Name("gridDensityChanged")
    static let viewModeChanged = Notification.Name("viewModeChanged")
}

class GridDensityManager {
    static let shared = GridDensityManager()

    private let densityKey = "gridDensity"
    private let viewModeKey = "viewMode"

    var currentDensity: DesignSystem.CardSize {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: densityKey),
               let density = DesignSystem.CardSize(rawValue: rawValue) {
                return density
            }
            return .comfortable
        }
        set {
            UserDefaults.standard.set(newValue.rawValueString, forKey: densityKey)
            NotificationCenter.default.post(name: .gridDensityChanged, object: nil)
        }
    }

    var currentViewMode: DesignSystem.ViewMode {
        get {
            if let rawValue = UserDefaults.standard.string(forKey: viewModeKey),
               let mode = DesignSystem.ViewMode(rawValue: rawValue) {
                return mode
            }
            return .list
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: viewModeKey)
            NotificationCenter.default.post(name: .viewModeChanged, object: nil)
        }
    }

    var currentThumbnailStyle: DesignSystem.ThumbnailStyle {
        return SettingsStore.shared.thumbnailStyle
    }

    private init() {}
}

extension DesignSystem.CardSize {
    init?(rawValue: String) {
        switch rawValue {
        case "compact": self = .compact
        case "comfortable": self = .comfortable
        case "large": self = .large
        default: return nil
        }
    }

    var rawValueString: String {
        switch self {
        case .compact: return "compact"
        case .comfortable: return "comfortable"
        case .large: return "large"
        }
    }
}

class AdaptiveGridLayout: NSCollectionViewLayout {
    private var itemAttributes: [NSCollectionViewLayoutAttributes] = []
    private var contentSize = NSSize.zero

    var viewMode: DesignSystem.ViewMode {
        return GridDensityManager.shared.currentViewMode
    }

    var density: DesignSystem.CardSize {
        return GridDensityManager.shared.currentDensity
    }

    override init() {
        super.init()
        setupNotifications()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNotifications()
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(layoutDidChange), name: .gridDensityChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(layoutDidChange), name: .viewModeChanged, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func layoutDidChange() { invalidateLayout() }

    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }

        itemAttributes.removeAll()

        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        if numberOfItems == 0 {
            contentSize = NSSize.zero
            return
        }

        let availableWidth = collectionView.bounds.width

        if viewMode == .grid {
            prepareGridLayout(numberOfItems: numberOfItems, availableWidth: availableWidth)
        } else {
            prepareListLayout(numberOfItems: numberOfItems, availableWidth: availableWidth)
        }
    }

    private func prepareGridLayout(numberOfItems: Int, availableWidth: CGFloat) {
        let currentDensity = density
        let cols = currentDensity.columnsCount
        let inset = currentDensity.sectionInset
        let gap = currentDensity.gap
        let itemWidth = floor((availableWidth - inset * 2 - gap * CGFloat(cols - 1)) / CGFloat(cols))
        let itemHeight = currentDensity.itemHeight

        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)

            let row = item / cols
            let col = item % cols

            let x = inset + CGFloat(col) * (itemWidth + gap)
            let y = inset + CGFloat(row) * (itemHeight + gap)

            attributes.frame = NSRect(x: x, y: y, width: itemWidth, height: itemHeight)
            itemAttributes.append(attributes)
        }

        let numberOfRows = (numberOfItems + cols - 1) / cols
        contentSize = NSSize(
            width: availableWidth,
            height: inset * 2 + CGFloat(numberOfRows) * itemHeight + CGFloat(max(0, numberOfRows - 1)) * gap
        )
    }

    private func prepareListLayout(numberOfItems: Int, availableWidth: CGFloat) {
        let inset: CGFloat = 4
        let itemHeight = DesignSystem.ListCard.height

        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)

            let y = inset + CGFloat(item) * itemHeight

            attributes.frame = NSRect(x: 0, y: y, width: availableWidth, height: itemHeight)
            itemAttributes.append(attributes)
        }

        contentSize = NSSize(
            width: availableWidth,
            height: inset * 2 + CGFloat(numberOfItems) * itemHeight
        )
    }

    override var collectionViewContentSize: NSSize { contentSize }

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
