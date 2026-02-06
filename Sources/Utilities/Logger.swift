import Foundation

/// Centralized logging utility with conditional debug output
enum Logger {
    /// Enable/disable debug logging - set to false for production
    #if DEBUG
    static let isEnabled = true
    #else
    static let isEnabled = false
    #endif

    enum Category: String {
        case ui = "UI"
        case dragDrop = "DragDrop"
        case clipboard = "Clipboard"
        case cell = "Cell"
        case layout = "Layout"
        case filter = "Filter"
        case persistence = "Persistence"
        case general = "General"
    }

    static func debug(_ message: String, category: Category = .general) {
        guard isEnabled else { return }
        print("[\(category.rawValue)] \(message)")
    }

    static func info(_ message: String, category: Category = .general) {
        guard isEnabled else { return }
        print("[\(category.rawValue)] ℹ️ \(message)")
    }

    static func warning(_ message: String, category: Category = .general) {
        guard isEnabled else { return }
        print("[\(category.rawValue)] ⚠️ \(message)")
    }

    static func error(_ message: String, category: Category = .general) {
        // Errors are always logged
        print("[\(category.rawValue)] ❌ \(message)")
    }
}
