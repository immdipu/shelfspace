import Cocoa

enum DesignSystem {
    // MARK: - View Mode

    enum ViewMode: String {
        case grid
        case list
    }

    // MARK: - Thumbnail Style

    enum ThumbnailStyle: String {
        case contain  // Fit image, may have letterbox gaps
        case cover    // Fill area, image may be cropped
    }

    // MARK: - Spacing

    enum Spacing {
        static let xs: CGFloat = 4.0
        static let sm: CGFloat = 8.0
        static let md: CGFloat = 12.0
        static let lg: CGFloat = 16.0
        static let xl: CGFloat = 24.0
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let sm: CGFloat = 6.0
        static let md: CGFloat = 10.0
        static let lg: CGFloat = 14.0
    }

    // MARK: - Typography

    enum Typography {
        static var title: NSFont { NSFont.systemFont(ofSize: 14, weight: .semibold) }
        static var subtitle: NSFont { NSFont.systemFont(ofSize: 13, weight: .medium) }
        static var body: NSFont { NSFont.systemFont(ofSize: 12, weight: .medium) }
        static var caption: NSFont { NSFont.systemFont(ofSize: 11, weight: .regular) }
        static var small: NSFont { NSFont.systemFont(ofSize: 10, weight: .medium) }
        static var badge: NSFont { NSFont.systemFont(ofSize: 9, weight: .semibold) }
        static var tiny: NSFont { NSFont.systemFont(ofSize: 9, weight: .medium) }
        static var mono: NSFont { NSFont.monospacedSystemFont(ofSize: 10, weight: .regular) }
        static var monoSmall: NSFont { NSFont.monospacedSystemFont(ofSize: 11, weight: .regular) }
    }

    // MARK: - Header Dimensions

    enum Header {
        static let height: CGFloat = 44
        static let tabBarHeight: CGFloat = 40
        static let toolbarHeight: CGFloat = 38
    }

    // MARK: - Grid Card

    enum GridCard {
        static let previewHeight: CGFloat = 100
        static let footerHeight: CGFloat = 44
        static let typeIconSize: CGFloat = 24
        static let cornerRadius: CGFloat = 12  // rounded-xl
        static let gap: CGFloat = 8  // gap-2
        static let sectionInset: CGFloat = 8
        static let columns: Int = 2  // Default (comfortable)
    }

    // MARK: - List Card

    enum ListCard {
        static let height: CGFloat = 52
        static let iconSize: CGFloat = 36
        static let iconCornerRadius: CGFloat = 6
        static let spacing: CGFloat = 0  // items are flush, hover fills
    }

    // MARK: - Action Buttons

    enum ActionButton {
        static let gridSize: CGFloat = 30
        static let listSize: CGFloat = 28
        static let gridCornerRadius: CGFloat = 5  // slightly softer at 24px
        static let listCornerRadius: CGFloat = 6  // rounded-md
    }

    // MARK: - Card Sizes (for density manager compatibility)

    enum CardSize {
        case compact
        case comfortable
        case large

        var columnsCount: Int {
            switch self {
            case .compact: return 3
            case .comfortable: return 2
            case .large: return 1
            }
        }

        var previewHeight: CGFloat {
            switch self {
            case .compact: return 80
            case .comfortable: return GridCard.previewHeight
            case .large: return 160
            }
        }

        var footerHeight: CGFloat {
            switch self {
            case .compact: return 38
            case .comfortable: return GridCard.footerHeight
            case .large: return 50
            }
        }

        var itemHeight: CGFloat {
            return previewHeight + footerHeight
        }

        var gap: CGFloat {
            switch self {
            case .compact: return 6
            case .comfortable: return GridCard.gap
            case .large: return 10
            }
        }

        var minimumInteritemSpacing: CGFloat { gap }
        var sectionInset: CGFloat { GridCard.sectionInset }

        func itemWidth(for availableWidth: CGFloat) -> CGFloat {
            let cols = CGFloat(columnsCount)
            let totalSpacing = sectionInset * 2 + minimumInteritemSpacing * (cols - 1)
            return floor((availableWidth - totalSpacing) / cols)
        }

        func itemSize(for availableWidth: CGFloat) -> NSSize {
            return NSSize(width: itemWidth(for: availableWidth), height: itemHeight)
        }
    }

    // MARK: - Shadows

    enum Shadow {
        static let cardHover = ShadowConfig(opacity: 0.3, radius: 12, offset: CGSize(width: 0, height: 4))

        struct ShadowConfig {
            let opacity: Float
            let radius: CGFloat
            let offset: CGSize
        }
    }

    // MARK: - Animation

    enum Animation {
        static let fast: CFTimeInterval = 0.1
        static let normal: CFTimeInterval = 0.15
        static let slow: CFTimeInterval = 0.2
        static let tabSwitch: CFTimeInterval = 0.25
    }
}
