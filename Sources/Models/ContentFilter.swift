import Foundation

enum ContentFilter: String, CaseIterable {
    case all = "All"
    case images = "Images"
    case text = "Text"
    case files = "Files"

    var iconName: String {
        switch self {
        case .all: return "tray.2"
        case .images: return "photo"
        case .text: return "doc.text"
        case .files: return "doc"
        }
    }
}
