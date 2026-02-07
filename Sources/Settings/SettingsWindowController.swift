import Cocoa

final class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    private init() {
        let tabViewController = SettingsTabViewController()
        let window = NSWindow(contentViewController: tabViewController)
        window.title = "Settings"
        window.setContentSize(NSSize(width: 520, height: 420))
        window.minSize = NSSize(width: 480, height: 380)
        window.styleMask = [.titled, .closable, .miniaturizable]
        window.center()
        window.isReleasedWhenClosed = false
        window.setFrameAutosaveName("SettingsWindow")
        window.titlebarAppearsTransparent = true
        window.backgroundColor = AppColors.background

        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show() {
        guard let window = window else { return }
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

final class SettingsTabViewController: NSTabViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = AppColors.background.cgColor

        tabStyle = .toolbar
        canPropagateSelectedChildViewControllerTitle = true

        let controllers: [NSViewController] = [
            GeneralSettingsViewController(),
            AppearanceSettingsViewController(),
            ClipboardSettingsViewController(),
            StorageSettingsViewController(),
            AdvancedSettingsViewController(),
            AboutSettingsViewController()
        ]

        controllers.forEach { addChild($0) }

        // Set icons
        let icons = ["gearshape", "paintbrush", "doc.on.clipboard", "tray.full", "gearshape.2", "info.circle"]
        for (index, item) in tabViewItems.enumerated() {
            if index < icons.count {
                item.image = NSImage(systemSymbolName: icons[index], accessibilityDescription: item.label)
            }
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.backgroundColor = AppColors.background
    }
}
