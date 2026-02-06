import Cocoa

struct AppColors {
    // MARK: - Background Layers

    /// Main background (#0D0D12)
    static let background = NSColor(red: 0.051, green: 0.051, blue: 0.071, alpha: 1.0)

    /// Header background (#13131A)
    static let headerBackground = NSColor(red: 0.075, green: 0.075, blue: 0.102, alpha: 1.0)

    /// Card background (#15151E)
    static let cardBackground = NSColor(red: 0.082, green: 0.082, blue: 0.118, alpha: 1.0)

    /// Card hover (#1C1C27)
    static let cardHover = NSColor(red: 0.110, green: 0.110, blue: 0.153, alpha: 1.0)

    /// List hover (#1A1A24)
    static let listHover = NSColor(red: 0.102, green: 0.102, blue: 0.141, alpha: 1.0)

    /// Elevated surfaces / icon backgrounds (#1E1E28)
    static let backgroundTertiary = NSColor(red: 0.118, green: 0.118, blue: 0.157, alpha: 1.0)

    /// Preview area background (#111119)
    static let previewBackground = NSColor(red: 0.067, green: 0.067, blue: 0.098, alpha: 1.0)

    // MARK: - Accent

    /// Primary purple (#8B5CF6)
    static let accent = NSColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 1.0)

    /// Light purple (#A78BFA)
    static let accentLight = NSColor(red: 0.655, green: 0.545, blue: 0.980, alpha: 1.0)

    /// Lavender for active tab text (#DDD6FE)
    static let accentLavender = NSColor(red: 0.867, green: 0.839, blue: 0.996, alpha: 1.0)

    // MARK: - Text

    /// Primary text (#EBEBEF)
    static let textPrimary = NSColor(red: 0.922, green: 0.922, blue: 0.937, alpha: 1.0)

    /// Secondary text (#A1A1AA)
    static let textSecondary = NSColor(red: 0.631, green: 0.631, blue: 0.667, alpha: 1.0)

    /// Tertiary text (#71717A)
    static let textTertiary = NSColor(red: 0.443, green: 0.443, blue: 0.478, alpha: 1.0)

    /// Dim text (#52525B)
    static let textDim = NSColor(red: 0.322, green: 0.322, blue: 0.357, alpha: 1.0)

    /// Darkest text (#3F3F46)
    static let textDarkest = NSColor(red: 0.247, green: 0.247, blue: 0.275, alpha: 1.0)

    /// Preview text (#6E6E82)
    static let previewText = NSColor(red: 0.431, green: 0.431, blue: 0.510, alpha: 1.0)

    /// Light text for button icons (#D4D4D8)
    static let textLight = NSColor(red: 0.831, green: 0.831, blue: 0.847, alpha: 1.0)

    // MARK: - Semantic

    /// Error red (#EF4444)
    static let error = NSColor(red: 0.937, green: 0.267, blue: 0.267, alpha: 1.0)

    /// Lighter error for hover (#F87171)
    static let errorLight = NSColor(red: 0.973, green: 0.443, blue: 0.443, alpha: 1.0)

    /// Success green (#22C55E)
    static let success = NSColor(red: 0.133, green: 0.773, blue: 0.369, alpha: 1.0)

    // MARK: - Borders

    /// Default border (#27272A)
    static let border = NSColor(red: 0.153, green: 0.153, blue: 0.165, alpha: 1.0)

    // MARK: - Derived Colors

    /// Subtle white overlay rgba(255,255,255,0.04)
    static let whiteOverlay4 = NSColor.white.withAlphaComponent(0.04)

    /// White overlay rgba(255,255,255,0.05)
    static let whiteOverlay5 = NSColor.white.withAlphaComponent(0.05)

    /// White overlay rgba(255,255,255,0.06)
    static let whiteOverlay6 = NSColor.white.withAlphaComponent(0.06)

    /// White overlay rgba(255,255,255,0.08)
    static let whiteOverlay8 = NSColor.white.withAlphaComponent(0.08)

    /// Accent bg for icon badges rgba(139,92,246,0.12)
    static let accentBadgeBg = NSColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.12)

    /// Accent for indicator gradient start rgba(139,92,246,0.18)
    static let accentGradientStart = NSColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.18)

    /// Accent for indicator gradient end rgba(139,92,246,0.08)
    static let accentGradientEnd = NSColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.08)

    /// Accent border rgba(139,92,246,0.2)
    static let accentBorder = NSColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.2)

    /// Accent for pinned border rgba(139,92,246,0.3)
    static let accentPinnedBorder = NSColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.3)

    /// Hover overlay rgba(13,13,18,0.7)
    static let hoverOverlay = NSColor(red: 0.051, green: 0.051, blue: 0.071, alpha: 0.7)

    /// Toolbar bg rgba(22,22,29,0.8)
    static let toolbarBackground = NSColor(red: 0.086, green: 0.086, blue: 0.114, alpha: 0.8)

    /// Accent file icon bg rgba(139,92,246,0.08)
    static let accentIconBg = NSColor(red: 0.545, green: 0.361, blue: 0.965, alpha: 0.08)

    // MARK: - Legacy Compatibility

    static var backgroundSecondary: NSColor { headerBackground }
    static var accentMuted: NSColor { accentBadgeBg }
    static var primary: NSColor { accent }
    static var borderLight: NSColor { NSColor(red: 0.247, green: 0.247, blue: 0.275, alpha: 1.0) }
    static var warning: NSColor { NSColor(red: 0.961, green: 0.620, blue: 0.043, alpha: 1.0) }
}
