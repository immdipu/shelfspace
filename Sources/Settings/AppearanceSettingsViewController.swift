import Cocoa

final class AppearanceSettingsViewController: SettingsPaneViewController {
    private let densityControl = NSSegmentedControl(labels: ["Compact", "Comfortable", "Large"], trackingMode: .selectOne, target: nil, action: nil)
    private let thumbnailStyleControl = NSSegmentedControl(labels: ["Contain", "Cover"], trackingMode: .selectOne, target: nil, action: nil)
    private let showFileSizeToggle = NSSwitch()
    private let cornerRadiusControl = NSSegmentedControl(labels: ["Square", "Rounded", "Pill"], trackingMode: .selectOne, target: nil, action: nil)

    init() {
        super.init(title: "Appearance", symbolName: "paintbrush")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        densityControl.target = self
        densityControl.action = #selector(densityChanged)
        densityControl.controlSize = .small
        densityControl.segmentStyle = .rounded

        thumbnailStyleControl.target = self
        thumbnailStyleControl.action = #selector(thumbnailStyleChanged)
        thumbnailStyleControl.controlSize = .small
        thumbnailStyleControl.segmentStyle = .rounded

        showFileSizeToggle.target = self
        showFileSizeToggle.action = #selector(showFileSizeChanged)
        showFileSizeToggle.controlSize = .small

        cornerRadiusControl.target = self
        cornerRadiusControl.action = #selector(cornerRadiusChanged)
        cornerRadiusControl.controlSize = .small
        cornerRadiusControl.segmentStyle = .rounded

        let gridSection = makeSection(
            title: "Grid Layout",
            rows: [
                makeRow(label: "Grid density", control: densityControl),
                makeRow(label: "Thumbnail style", control: thumbnailStyleControl),
            ]
        )

        let cardSection = makeSection(
            title: "Cards",
            rows: [
                makeRow(label: "Card corners", control: cornerRadiusControl),
                makeRow(label: "Show file size", control: showFileSizeToggle),
            ]
        )

        addSection(gridSection)
        addSection(cardSection)
        syncUI()

        NotificationCenter.default.addObserver(self, selector: #selector(syncUI), name: .settingsDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncUI), name: .settingsDidReset, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    @objc private func densityChanged() {
        let densities: [DesignSystem.CardSize] = [.compact, .comfortable, .large]
        let index = densityControl.selectedSegment
        guard densities.indices.contains(index) else { return }
        GridDensityManager.shared.currentDensity = densities[index]
    }

    @objc private func thumbnailStyleChanged() {
        let styles: [DesignSystem.ThumbnailStyle] = [.contain, .cover]
        let index = thumbnailStyleControl.selectedSegment
        guard styles.indices.contains(index) else { return }
        SettingsStore.shared.thumbnailStyle = styles[index]
    }

    @objc private func showFileSizeChanged() {
        SettingsStore.shared.showFileSizeInGrid = showFileSizeToggle.state == .on
    }

    @objc private func cornerRadiusChanged() {
        let radii = [4, 12, 20]
        let index = cornerRadiusControl.selectedSegment
        guard radii.indices.contains(index) else { return }
        SettingsStore.shared.cardCornerRadius = radii[index]
    }

    @objc private func syncUI() {
        let density = GridDensityManager.shared.currentDensity
        switch density {
        case .compact:
            densityControl.selectedSegment = 0
        case .comfortable:
            densityControl.selectedSegment = 1
        case .large:
            densityControl.selectedSegment = 2
        }

        let thumbStyle = SettingsStore.shared.thumbnailStyle
        thumbnailStyleControl.selectedSegment = (thumbStyle == .contain) ? 0 : 1

        showFileSizeToggle.state = SettingsStore.shared.showFileSizeInGrid ? .on : .off

        let radius = SettingsStore.shared.cardCornerRadius
        if radius <= 4 {
            cornerRadiusControl.selectedSegment = 0
        } else if radius <= 12 {
            cornerRadiusControl.selectedSegment = 1
        } else {
            cornerRadiusControl.selectedSegment = 2
        }
    }
}
