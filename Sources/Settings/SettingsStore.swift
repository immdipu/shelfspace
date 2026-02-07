import Foundation
import ServiceManagement

extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
    static let settingsDidReset = Notification.Name("settingsDidReset")

    static let settingsClipboardMonitoringChanged = Notification.Name("settingsClipboardMonitoringChanged")
    static let settingsPollingIntervalChanged = Notification.Name("settingsPollingIntervalChanged")
    static let settingsShowInDockChanged = Notification.Name("settingsShowInDockChanged")
    static let settingsMaxItemsChanged = Notification.Name("settingsMaxItemsChanged")
    static let settingsRetentionChanged = Notification.Name("settingsRetentionChanged")

    static let settingsDidRequestClearUnpinned = Notification.Name("settingsDidRequestClearUnpinned")
    static let settingsDidRequestClearAll = Notification.Name("settingsDidRequestClearAll")
}

final class SettingsStore {
    static let shared = SettingsStore()

    private let defaults = UserDefaults.standard

    private enum Keys {
        static let showMenuBarIcon = "settings.showMenuBarIcon"
        static let showInDock = "settings.showInDock"
        static let clipboardMonitoringEnabled = "settings.clipboardMonitoringEnabled"
        static let captureFiles = "settings.captureFiles"
        static let captureImages = "settings.captureImages"
        static let captureText = "settings.captureText"
        static let pollingInterval = "settings.pollingInterval"
        static let maxFileSizeMB = "settings.maxFileSizeMB"
        static let maxTextLength = "settings.maxTextLength"
        static let maxItems = "settings.maxItems"
        static let autoClearDays = "settings.autoClearDays"
        static let ignoreDuplicates = "settings.ignoreDuplicates"
    }

    private enum Defaults {
        static let showMenuBarIcon = true
        static let showInDock = false
        static let clipboardMonitoringEnabled = true
        static let captureFiles = true
        static let captureImages = true
        static let captureText = true
        static let pollingInterval: TimeInterval = 0.5
        static let maxFileSizeMB = 200
        static let maxTextLength = 10_000
        static let maxItems = 50
        static let autoClearDays = 0
        static let ignoreDuplicates = false
    }

    private init() {
        defaults.register(defaults: [
            Keys.showMenuBarIcon: Defaults.showMenuBarIcon,
            Keys.showInDock: Defaults.showInDock,
            Keys.clipboardMonitoringEnabled: Defaults.clipboardMonitoringEnabled,
            Keys.captureFiles: Defaults.captureFiles,
            Keys.captureImages: Defaults.captureImages,
            Keys.captureText: Defaults.captureText,
            Keys.pollingInterval: Defaults.pollingInterval,
            Keys.maxFileSizeMB: Defaults.maxFileSizeMB,
            Keys.maxTextLength: Defaults.maxTextLength,
            Keys.maxItems: Defaults.maxItems,
            Keys.autoClearDays: Defaults.autoClearDays,
            Keys.ignoreDuplicates: Defaults.ignoreDuplicates
        ])
    }

    private func bool(forKey key: String, default defaultValue: Bool) -> Bool {
        guard defaults.object(forKey: key) != nil else { return defaultValue }
        return defaults.bool(forKey: key)
    }

    private func int(forKey key: String, default defaultValue: Int) -> Int {
        guard defaults.object(forKey: key) != nil else { return defaultValue }
        return defaults.integer(forKey: key)
    }

    private func double(forKey key: String, default defaultValue: Double) -> Double {
        guard defaults.object(forKey: key) != nil else { return defaultValue }
        return defaults.double(forKey: key)
    }

    var showMenuBarIcon: Bool {
        get { bool(forKey: Keys.showMenuBarIcon, default: Defaults.showMenuBarIcon) }
        set {
            defaults.set(newValue, forKey: Keys.showMenuBarIcon)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var showInDock: Bool {
        get { bool(forKey: Keys.showInDock, default: Defaults.showInDock) }
        set {
            defaults.set(newValue, forKey: Keys.showInDock)
            NotificationCenter.default.post(name: .settingsShowInDockChanged, object: nil)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var clipboardMonitoringEnabled: Bool {
        get { bool(forKey: Keys.clipboardMonitoringEnabled, default: Defaults.clipboardMonitoringEnabled) }
        set {
            defaults.set(newValue, forKey: Keys.clipboardMonitoringEnabled)
            NotificationCenter.default.post(name: .settingsClipboardMonitoringChanged, object: nil)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var captureFiles: Bool {
        get { bool(forKey: Keys.captureFiles, default: Defaults.captureFiles) }
        set {
            defaults.set(newValue, forKey: Keys.captureFiles)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var captureImages: Bool {
        get { bool(forKey: Keys.captureImages, default: Defaults.captureImages) }
        set {
            defaults.set(newValue, forKey: Keys.captureImages)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var captureText: Bool {
        get { bool(forKey: Keys.captureText, default: Defaults.captureText) }
        set {
            defaults.set(newValue, forKey: Keys.captureText)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var pollingInterval: TimeInterval {
        get { double(forKey: Keys.pollingInterval, default: Defaults.pollingInterval) }
        set {
            defaults.set(newValue, forKey: Keys.pollingInterval)
            NotificationCenter.default.post(name: .settingsPollingIntervalChanged, object: nil)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var maxFileSizeMB: Int {
        get { int(forKey: Keys.maxFileSizeMB, default: Defaults.maxFileSizeMB) }
        set {
            defaults.set(newValue, forKey: Keys.maxFileSizeMB)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var maxTextLength: Int {
        get { int(forKey: Keys.maxTextLength, default: Defaults.maxTextLength) }
        set {
            defaults.set(newValue, forKey: Keys.maxTextLength)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var maxItems: Int {
        get { int(forKey: Keys.maxItems, default: Defaults.maxItems) }
        set {
            defaults.set(newValue, forKey: Keys.maxItems)
            NotificationCenter.default.post(name: .settingsMaxItemsChanged, object: nil)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var autoClearDays: Int {
        get { int(forKey: Keys.autoClearDays, default: Defaults.autoClearDays) }
        set {
            defaults.set(newValue, forKey: Keys.autoClearDays)
            NotificationCenter.default.post(name: .settingsRetentionChanged, object: nil)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var ignoreDuplicates: Bool {
        get { bool(forKey: Keys.ignoreDuplicates, default: Defaults.ignoreDuplicates) }
        set {
            defaults.set(newValue, forKey: Keys.ignoreDuplicates)
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }

    var launchAtLoginEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        }
        return false
    }

    @discardableResult
    func setLaunchAtLoginEnabled(_ enabled: Bool) -> Bool {
        guard #available(macOS 13.0, *) else { return false }
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
            return true
        } catch {
            return false
        }
    }

    func resetToDefaults() {
        defaults.removeObject(forKey: Keys.showMenuBarIcon)
        defaults.removeObject(forKey: Keys.showInDock)
        defaults.removeObject(forKey: Keys.clipboardMonitoringEnabled)
        defaults.removeObject(forKey: Keys.captureFiles)
        defaults.removeObject(forKey: Keys.captureImages)
        defaults.removeObject(forKey: Keys.captureText)
        defaults.removeObject(forKey: Keys.pollingInterval)
        defaults.removeObject(forKey: Keys.maxFileSizeMB)
        defaults.removeObject(forKey: Keys.maxTextLength)
        defaults.removeObject(forKey: Keys.maxItems)
        defaults.removeObject(forKey: Keys.autoClearDays)
        defaults.removeObject(forKey: Keys.ignoreDuplicates)

        _ = setLaunchAtLoginEnabled(false)

        NotificationCenter.default.post(name: .settingsDidReset, object: nil)
        NotificationCenter.default.post(name: .settingsDidChange, object: nil)
    }
}
