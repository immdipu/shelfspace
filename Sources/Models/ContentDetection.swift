import Cocoa

/// What a text clip's content actually is, beyond "text"
enum DetectedContent {
    case link(URL)
    case color(NSColor, hex: String)
    case email(String)
    case plain

    var badgeText: String? {
        switch self {
        case .link: return "LINK"
        case .color: return "COLOR"
        case .email: return "EMAIL"
        case .plain: return nil
        }
    }

    var iconName: String? {
        switch self {
        case .link: return "link"
        case .color: return "paintpalette"
        case .email: return "envelope"
        case .plain: return nil
        }
    }
}

extension FileShelfItem {
    private static let detectionCache = NSCache<NSUUID, DetectionBox>()

    final class DetectionBox {
        let content: DetectedContent
        init(_ content: DetectedContent) { self.content = content }
    }

    var detectedContent: DetectedContent {
        if let cached = Self.detectionCache.object(forKey: id as NSUUID) {
            return cached.content
        }
        let result = Self.detect(in: isText ? textContent : nil)
        Self.detectionCache.setObject(DetectionBox(result), forKey: id as NSUUID)
        return result
    }

    private static func detect(in text: String?) -> DetectedContent {
        guard let text = text else { return .plain }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        // Only single-token clips qualify — a paragraph containing a URL is still text
        guard !trimmed.isEmpty, trimmed.count <= 2048, !trimmed.contains(where: \.isNewline) else { return .plain }

        if let color = parseColor(trimmed) {
            return .color(color, hex: trimmed)
        }

        let fullRange = NSRange(trimmed.startIndex..., in: trimmed)
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue),
           let match = detector.firstMatch(in: trimmed, options: [], range: fullRange),
           match.range == fullRange,
           let url = match.url {
            if url.scheme == "mailto" {
                return .email(String(trimmed))
            }
            return .link(url)
        }

        return .plain
    }

    /// Parses #RGB, #RRGGBB, #RRGGBBAA hex color strings
    private static func parseColor(_ text: String) -> NSColor? {
        guard text.hasPrefix("#") else { return nil }
        var hex = String(text.dropFirst()).lowercased()
        guard hex.count == 3 || hex.count == 6 || hex.count == 8,
              hex.allSatisfy({ $0.isHexDigit }) else { return nil }

        if hex.count == 3 {
            hex = hex.map { "\($0)\($0)" }.joined()
        }
        var value: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&value) else { return nil }

        let r, g, b, a: CGFloat
        if hex.count == 8 {
            r = CGFloat((value >> 24) & 0xFF) / 255
            g = CGFloat((value >> 16) & 0xFF) / 255
            b = CGFloat((value >> 8) & 0xFF) / 255
            a = CGFloat(value & 0xFF) / 255
        } else {
            r = CGFloat((value >> 16) & 0xFF) / 255
            g = CGFloat((value >> 8) & 0xFF) / 255
            b = CGFloat(value & 0xFF) / 255
            a = 1
        }
        return NSColor(red: r, green: g, blue: b, alpha: a)
    }
}
