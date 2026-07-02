import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    var popover: NSPopover!
    var fileShelfViewController: FileShelfViewController!
    var clipboardMonitor: ClipboardMonitor!
    var window: NSWindow!
    
    // App version information
    static var appVersion: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
    }
    
    static var buildNumber: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
    }
    
    static var appName: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String ?? "ShelfSpace"
    }
    
    static var copyright: String {
        return Bundle.main.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? "Copyright © 2026 Dipu"
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupPopover()
        setupClipboardMonitor()
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        clipboardMonitor.stop()
    }
    
    private func setupMenuBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusBarItem.button {
            // Use SF Symbol for the menu bar icon
            button.image = NSImage(systemSymbolName: "cube.box", accessibilityDescription: "ShelfSpace")
            button.action = #selector(statusBarButtonClicked(_:))
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc private func statusBarButtonClicked(_ sender: AnyObject?) {
        if NSApp.currentEvent?.type == .rightMouseUp {
            showStatusBarMenu()
        } else {
            togglePopover(sender)
        }
    }

    private func showStatusBarMenu() {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: "Open ShelfSpace", action: #selector(showPopover(_:)), keyEquivalent: "")
        openItem.target = self
        menu.addItem(openItem)

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(showSettingsWindow), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(title: "Quit ShelfSpace", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        // Assign temporarily so left-click keeps toggling the popover
        statusBarItem.menu = menu
        statusBarItem.button?.performClick(nil)
        statusBarItem.menu = nil
    }

    @objc private func showSettingsWindow() {
        SettingsWindowController.shared.show()
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 420, height: 600)
        popover.behavior = .semitransient // Changed from .transient to allow drag and drop
        popover.animates = true
        
        fileShelfViewController = FileShelfViewController()
        popover.contentViewController = fileShelfViewController
    }
    
    private func setupClipboardMonitor() {
        clipboardMonitor = ClipboardMonitor { [weak self] items in
            DispatchQueue.main.async {
                self?.fileShelfViewController.addItems(items)
            }
        }
        if SettingsStore.shared.clipboardMonitoringEnabled {
            clipboardMonitor.start()
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            closePopover(sender)
        } else {
            showPopover(sender)
        }
    }
    
    @objc func showPopover(_ sender: AnyObject?) {
        if let button = statusBarItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    @objc func closePopover(_ sender: AnyObject?) {
        popover.performClose(sender)
    }
    
    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }
} 