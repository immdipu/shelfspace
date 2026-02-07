import Cocoa

final class AppearanceSettingsViewController: SettingsPaneViewController {
    private let viewModeControl = NSSegmentedControl(labels: ["List", "Grid"], trackingMode: .selectOne, target: nil, action: nil)
    private let densityControl = NSSegmentedControl(labels: ["Compact", "Comfortable", "Large"], trackingMode: .selectOne, target: nil, action: nil)

    init() {
        super.init(title: "Appearance", symbolName: "paintbrush")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModeControl.target = self
        viewModeControl.action = #selector(viewModeChanged)
        viewModeControl.controlSize = .small
        viewModeControl.segmentStyle = .rounded

        densityControl.target = self
        densityControl.action = #selector(densityChanged)
        densityControl.controlSize = .small
        densityControl.segmentStyle = .rounded

        let viewSection = makeSection(
            title: "Display",
            rows: [
                makeRow(label: "Default view", control: viewModeControl),
                makeRow(label: "Grid density", control: densityControl)
            ]
        )

        addSection(viewSection)
        syncUI()

        NotificationCenter.default.addObserver(self, selector: #selector(syncUI), name: .settingsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncUI), name: .settingsDidReset, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func viewModeChanged() {
        let selectedIndex = viewModeControl.selectedSegment
        let mode: DesignSystem.ViewMode = (selectedIndex == 0) ? .list : .grid
        GridDensityManager.shared.currentViewMode = mode
    }

    @objc private func densityChanged() {
        let densities: [DesignSystem.CardSize] = [.compact, .comfortable, .large]
        let index = densityControl.selectedSegment
        guard densities.indices.contains(index) else { return }
        GridDensityManager.shared.currentDensity = densities[index]
    }

    @objc private func syncUI() {
        let viewMode = GridDensityManager.shared.currentViewMode
        viewModeControl.selectedSegment = (viewMode == .list) ? 0 : 1

        let density = GridDensityManager.shared.currentDensity
        switch density {
        case .compact:
            densityControl.selectedSegment = 0
        case .comfortable:
            densityControl.selectedSegment = 1
        case .large:
            densityControl.selectedSegment = 2
        }
    }
}
