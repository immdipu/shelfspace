import Cocoa

final class ClipboardSettingsViewController: SettingsPaneViewController {
    private let monitoringToggle = NSSwitch()
    private let captureFilesToggle = NSSwitch()
    private let captureImagesToggle = NSSwitch()
    private let captureTextToggle = NSSwitch()
    private let ignoreDuplicatesToggle = NSSwitch()

    private let pollingPopup = NSPopUpButton()
    private let maxFileSizePopup = NSPopUpButton()
    private let maxTextLengthPopup = NSPopUpButton()

    private let pollingIntervals: [TimeInterval] = [0.25, 0.5, 1.0, 2.0]
    private let pollingLabels = ["0.25s", "0.5s", "1s", "2s"]

    private let maxFileSizesMB = [50, 100, 200, 500]
    private let maxTextLengths = [2_000, 10_000, 50_000]

    init() {
        super.init(title: "Clipboard", symbolName: "doc.on.clipboard")
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
        [monitoringToggle, captureFilesToggle, captureImagesToggle, captureTextToggle, ignoreDuplicatesToggle].forEach {
            $0.controlSize = .small
        }

        monitoringToggle.target = self
        monitoringToggle.action = #selector(monitoringToggled)

        captureFilesToggle.target = self
        captureFilesToggle.action = #selector(captureToggled)

        captureImagesToggle.target = self
        captureImagesToggle.action = #selector(captureToggled)

        captureTextToggle.target = self
        captureTextToggle.action = #selector(captureToggled)

        ignoreDuplicatesToggle.target = self
        ignoreDuplicatesToggle.action = #selector(ignoreDuplicatesToggled)

        pollingPopup.controlSize = .small
        pollingPopup.font = NSFont.systemFont(ofSize: 11)
        pollingPopup.addItems(withTitles: pollingLabels)
        pollingPopup.target = self
        pollingPopup.action = #selector(pollingIntervalChanged)

        maxFileSizePopup.controlSize = .small
        maxFileSizePopup.font = NSFont.systemFont(ofSize: 11)
        maxFileSizePopup.addItems(withTitles: maxFileSizesMB.map { "\($0) MB" })
        maxFileSizePopup.target = self
        maxFileSizePopup.action = #selector(maxFileSizeChanged)

        maxTextLengthPopup.controlSize = .small
        maxTextLengthPopup.font = NSFont.systemFont(ofSize: 11)
        maxTextLengthPopup.addItems(withTitles: maxTextLengths.map { formatNumber($0) })
        maxTextLengthPopup.target = self
        maxTextLengthPopup.action = #selector(maxTextLengthChanged)
    }

    private func formatNumber(_ number: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? "\(number)"
    }

    private func buildSections() {
        let monitoringSection = makeSection(
            title: "Monitoring",
            rows: [
                makeRow(label: "Enable clipboard monitoring", control: monitoringToggle),
                makeRow(label: "Polling interval", control: pollingPopup)
            ]
        )

        let captureSection = makeSection(
            title: "Capture Types",
            rows: [
                makeRow(label: "Files", control: captureFilesToggle),
                makeRow(label: "Images", control: captureImagesToggle),
                makeRow(label: "Text", control: captureTextToggle)
            ]
        )

        let limitsSection = makeSection(
            title: "Limits",
            rows: [
                makeRow(label: "Max file size", control: maxFileSizePopup),
                makeRow(label: "Max text length", control: maxTextLengthPopup),
                makeRow(label: "Ignore duplicates", control: ignoreDuplicatesToggle)
            ]
        )

        addSection(monitoringSection)
        addSection(captureSection)
        addSection(limitsSection)
    }

    @objc private func monitoringToggled() {
        SettingsStore.shared.clipboardMonitoringEnabled = monitoringToggle.state == .on
    }

    @objc private func captureToggled() {
        SettingsStore.shared.captureFiles = captureFilesToggle.state == .on
        SettingsStore.shared.captureImages = captureImagesToggle.state == .on
        SettingsStore.shared.captureText = captureTextToggle.state == .on
    }

    @objc private func ignoreDuplicatesToggled() {
        SettingsStore.shared.ignoreDuplicates = ignoreDuplicatesToggle.state == .on
    }

    @objc private func pollingIntervalChanged() {
        let index = pollingPopup.indexOfSelectedItem
        guard pollingIntervals.indices.contains(index) else { return }
        SettingsStore.shared.pollingInterval = pollingIntervals[index]
    }

    @objc private func maxFileSizeChanged() {
        let index = maxFileSizePopup.indexOfSelectedItem
        guard maxFileSizesMB.indices.contains(index) else { return }
        SettingsStore.shared.maxFileSizeMB = maxFileSizesMB[index]
    }

    @objc private func maxTextLengthChanged() {
        let index = maxTextLengthPopup.indexOfSelectedItem
        guard maxTextLengths.indices.contains(index) else { return }
        SettingsStore.shared.maxTextLength = maxTextLengths[index]
    }

    @objc private func syncUI() {
        let settings = SettingsStore.shared
        monitoringToggle.state = settings.clipboardMonitoringEnabled ? .on : .off
        captureFilesToggle.state = settings.captureFiles ? .on : .off
        captureImagesToggle.state = settings.captureImages ? .on : .off
        captureTextToggle.state = settings.captureText ? .on : .off
        ignoreDuplicatesToggle.state = settings.ignoreDuplicates ? .on : .off

        if let index = pollingIntervals.firstIndex(of: settings.pollingInterval) {
            pollingPopup.selectItem(at: index)
        }

        if let index = maxFileSizesMB.firstIndex(of: settings.maxFileSizeMB) {
            maxFileSizePopup.selectItem(at: index)
        }

        if let index = maxTextLengths.firstIndex(of: settings.maxTextLength) {
            maxTextLengthPopup.selectItem(at: index)
        }
    }
}
