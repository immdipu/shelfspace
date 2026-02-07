import Cocoa

final class GeneralSettingsViewController: SettingsPaneViewController {
    private let showMenuBarIconToggle = NSSwitch()
    private let launchAtLoginToggle = NSSwitch()
    private let showInDockToggle = NSSwitch()

    init() {
        super.init(title: "General", symbolName: "gearshape")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureControls()
        buildSections()
        syncUI()

        NotificationCenter.default.addObserver(self, selector: #selector(syncUI), name: .settingsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncUI), name: .settingsDidReset, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func configureControls() {
        showMenuBarIconToggle.target = self
        showMenuBarIconToggle.action = #selector(showMenuBarIconChanged)
        showMenuBarIconToggle.controlSize = .small

        launchAtLoginToggle.target = self
        launchAtLoginToggle.action = #selector(launchAtLoginChanged)
        launchAtLoginToggle.controlSize = .small

        showInDockToggle.target = self
        showInDockToggle.action = #selector(showInDockChanged)
        showInDockToggle.controlSize = .small
    }

    private func buildSections() {
        let systemSection = makeSection(
            title: "System",
            rows: [
                makeRow(label: "Show menu bar icon", control: showMenuBarIconToggle),
                makeRow(label: "Launch at login", control: launchAtLoginToggle),
                makeRow(label: "Show in Dock", control: showInDockToggle)
            ]
        )

        addSection(systemSection)
    }

    @objc private func showMenuBarIconChanged() {
        SettingsStore.shared.showMenuBarIcon = showMenuBarIconToggle.state == .on
    }

    @objc private func launchAtLoginChanged() {
        let enabled = launchAtLoginToggle.state == .on
        let success = SettingsStore.shared.setLaunchAtLoginEnabled(enabled)
        if !success {
            showLaunchAtLoginError()
            syncUI()
        }
    }

    @objc private func showInDockChanged() {
        SettingsStore.shared.showInDock = showInDockToggle.state == .on
    }

    @objc private func syncUI() {
        showMenuBarIconToggle.state = SettingsStore.shared.showMenuBarIcon ? .on : .off
        launchAtLoginToggle.state = SettingsStore.shared.launchAtLoginEnabled ? .on : .off
        showInDockToggle.state = SettingsStore.shared.showInDock ? .on : .off
    }

    private func showLaunchAtLoginError() {
        let alert = NSAlert()
        alert.messageText = "Couldn't update Launch at Login"
        alert.informativeText = "macOS didn't allow ShelfSpace to change the login item. Please try again in System Settings → General → Login Items."
        alert.alertStyle = .warning

        if let window = view.window {
            alert.beginSheetModal(for: window)
        } else {
            alert.runModal()
        }
    }
}
