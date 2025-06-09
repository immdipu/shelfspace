import Cocoa

struct AppColors {
    // Primary signature color - a modern blue-purple gradient feel
    static let primary = NSColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)        // #3366E6
    static let primaryLight = NSColor(red: 0.3, green: 0.5, blue: 0.95, alpha: 1.0)  // #4D80F2
    static let primaryDark = NSColor(red: 0.15, green: 0.3, blue: 0.8, alpha: 1.0)   // #264DCC
    
    // Accent colors
    static let accent = NSColor(red: 0.9, green: 0.3, blue: 0.5, alpha: 1.0)         // #E64D80
    static let success = NSColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)        // #33CC66
    static let warning = NSColor(red: 0.9, green: 0.7, blue: 0.2, alpha: 1.0)        // #E6B533
    
    // Semantic colors that adapt to system appearance
    static var background: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.controlBackgroundColor
        } else {
            return NSColor.windowBackgroundColor
        }
    }
    
    static var cardBackground: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.controlBackgroundColor
        } else {
            return NSColor.white
        }
    }
    
    static var text: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.labelColor
        } else {
            return NSColor.black
        }
    }
    
    static var secondaryText: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.secondaryLabelColor
        } else {
            return NSColor.gray
        }
    }
    
    static var separator: NSColor {
        if #available(macOS 10.14, *) {
            return NSColor.separatorColor
        } else {
            return NSColor.lightGray
        }
    }
    
    // Tab colors
    static let tabSelected = primary
    static let tabUnselected = NSColor.systemGray
    
    // Button overlay colors with better contrast
    static let buttonOverlay = NSColor.black.withAlphaComponent(0.6)
    static let buttonBackground = NSColor.white.withAlphaComponent(0.95)
    static let buttonBackgroundHover = primary.withAlphaComponent(0.9)
} 