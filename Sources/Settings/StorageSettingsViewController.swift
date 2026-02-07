import Cocoa

final class StorageSettingsViewController: SettingsPaneViewController {
    private let maxItemsPopup = NSPopUpButton()
    private let autoClearPopup = NSPopUpButton()
    private let storageUsedLabel = NSTextField(labelWithString: "—")

    private let maxItemsOptions = [200, 500, 1000, 2000]
    private let autoClearOptions: [(label: String, days: Int)] = [
        ("Never", 0),
        ("1 day", 1),
        ("7 days", 7),
        ("30 days", 30)
    ]

    init() {
        super.init(title: "Storage", symbolName: "tray.full")
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
        maxItemsPopup.controlSize = .small
        maxItemsPopup.font = NSFont.systemFont(ofSize: 11)
        maxItemsPopup.addItems(withTitles: maxItemsOptions.map { "\($0)" })
        maxItemsPopup.target = self
        maxItemsPopup.action = #selector(maxItemsChanged)

        autoClearPopup.controlSize = .small
        autoClearPopup.font = NSFont.systemFont(ofSize: 11)
        autoClearPopup.addItems(withTitles: autoClearOptions.map { $0.label })
        autoClearPopup.target = self
        autoClearPopup.action = #selector(autoClearChanged)

        storageUsedLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .regular)
        storageUsedLabel.textColor = AppColors.textSecondary
    }

    private func buildSections() {
        let retentionSection = makeSection(
            title: "Retention",
            rows: [
                makeRow(label: "Maximum items", control: maxItemsPopup),
                makeRow(label: "Auto-clear after", control: autoClearPopup)
            ]
        )

        let actionsSection = makeSection(
            title: "Actions",
            rows: [
                makeActionRow(
                    title: "Clear unpinned",
                    description: "Remove all unpinned items",
                    buttonTitle: "Clear",
                    action: #selector(clearUnpinned)
                ),
                makeActionRow(
                    title: "Clear all history",
                    description: "Delete everything including pinned",
                    buttonTitle: "Clear All",
                    action: #selector(clearAll),
                    isDestructive: true
                )
            ]
        )

        let storageSection = makeSection(
            title: "Storage",
            rows: [
                makeRow(label: "Storage used", control: storageUsedLabel),
                makeActionRow(
                    title: "Storage folder",
                    description: "View files in Finder",
                    buttonTitle: "Show",
                    action: #selector(openStorageFolder)
                )
            ]
        )

        addSection(retentionSection)
        addSection(actionsSection)
        addSection(storageSection)
    }

    private func makeActionRow(title: String, description: String, buttonTitle: String, action: Selector, isDestructive: Bool = false) -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let textStack = NSView()
        textStack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(textStack)

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: 13)
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        textStack.addSubview(titleLabel)

        let descLabel = NSTextField(labelWithString: description)
        descLabel.font = NSFont.systemFont(ofSize: 10)
        descLabel.textColor = AppColors.textTertiary
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        textStack.addSubview(descLabel)

        let button = NSButton(title: buttonTitle, target: self, action: action)
        button.bezelStyle = .rounded
        button.controlSize = .small
        button.font = NSFont.systemFont(ofSize: 11)
        if isDestructive {
            button.contentTintColor = AppColors.error
        }
        button.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(button)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: textStack.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),

            descLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 1),
            descLabel.leadingAnchor.constraint(equalTo: textStack.leadingAnchor),
            descLabel.trailingAnchor.constraint(equalTo: textStack.trailingAnchor),
            descLabel.bottomAnchor.constraint(equalTo: textStack.bottomAnchor),

            textStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textStack.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            button.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            button.centerYAnchor.constraint(equalTo: container.centerYAnchor),

            container.heightAnchor.constraint(greaterThanOrEqualToConstant: 36),
        ])

        return container
    }

    @objc private func maxItemsChanged() {
        let index = maxItemsPopup.indexOfSelectedItem
        guard maxItemsOptions.indices.contains(index) else { return }
        SettingsStore.shared.maxItems = maxItemsOptions[index]
    }

    @objc private func autoClearChanged() {
        let index = autoClearPopup.indexOfSelectedItem
        guard autoClearOptions.indices.contains(index) else { return }
        SettingsStore.shared.autoClearDays = autoClearOptions[index].days
    }

    @objc private func clearUnpinned() {
        NotificationCenter.default.post(name: .settingsDidRequestClearUnpinned, object: nil)
        refreshStorageUsageSoon()
    }

    @objc private func clearAll() {
        let alert = NSAlert()
        alert.messageText = "Clear all history?"
        alert.informativeText = "This removes all items, including pinned ones. This action can't be undone."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Clear All")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            NotificationCenter.default.post(name: .settingsDidRequestClearAll, object: nil)
            refreshStorageUsageSoon()
        }
    }

    @objc private func openStorageFolder() {
        let url = PersistenceManager.shared.appSupportURL
        NSWorkspace.shared.open(url)
    }

    @objc private func syncUI() {
        let settings = SettingsStore.shared

        if let index = maxItemsOptions.firstIndex(of: settings.maxItems) {
            maxItemsPopup.selectItem(at: index)
        }

        if let index = autoClearOptions.firstIndex(where: { $0.days == settings.autoClearDays }) {
            autoClearPopup.selectItem(at: index)
        }

        updateStorageUsage()
    }

    private func updateStorageUsage() {
        let bytes = PersistenceManager.shared.storageUsageBytes()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        storageUsedLabel.stringValue = formatter.string(fromByteCount: bytes)
    }

    private func refreshStorageUsageSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            self?.updateStorageUsage()
        }
    }
}
