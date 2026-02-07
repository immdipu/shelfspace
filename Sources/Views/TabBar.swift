import Cocoa

protocol TabBarDelegate: AnyObject {
    func tabBar(_ tabBar: TabBar, didSelectFilter filter: ContentFilter)
    func tabBar(_ tabBar: TabBar, didChangeViewMode viewMode: DesignSystem.ViewMode)
}

class TabBar: NSView {
    weak var delegate: TabBarDelegate?

    private var tabButtons: [SegmentedTab] = []
    private let tabContainer = NSView()
    private let indicatorLayer = CALayer()
    private let viewToggleContainer = NSView()
    private let listToggle = ViewToggleButton(symbolName: "list.bullet", label: "List view")
    private let gridToggle = ViewToggleButton(symbolName: "square.grid.2x2", label: "Grid view")
    private let bottomBorder = NSView()

    private var currentFilter: ContentFilter = .all
    private var currentViewMode: DesignSystem.ViewMode = .list
    private var hiddenFilters: Set<ContentFilter> = []

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
        observeCaptureSettings()
        updateTabVisibility()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        observeCaptureSettings()
        updateTabVisibility()
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func observeCaptureSettings() {
        NotificationCenter.default.addObserver(self, selector: #selector(captureSettingsChanged), name: .settingsCaptureTypesChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(captureSettingsChanged), name: .settingsDidReset, object: nil)
    }

    @objc private func captureSettingsChanged() {
        updateTabVisibility()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = AppColors.background.cgColor

        setupTabContainer()
        setupTabs()
        setupIndicator()
        setupViewToggle()
        setupBottomBorder()
        setupConstraints()
    }

    private func setupTabContainer() {
        // Segmented control container: rounded-lg, p-3px, bg rgba(255,255,255,0.04)
        tabContainer.wantsLayer = true
        tabContainer.layer?.backgroundColor = AppColors.whiteOverlay4.cgColor
        tabContainer.layer?.cornerRadius = 8
        tabContainer.layer?.borderWidth = 1
        tabContainer.layer?.borderColor = AppColors.whiteOverlay4.cgColor
        tabContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(tabContainer)
    }

    private func setupTabs() {
        for filter in ContentFilter.allCases {
            let tab = SegmentedTab(filter: filter)
            tab.target = self
            tab.action = #selector(tabClicked(_:))
            tab.translatesAutoresizingMaskIntoConstraints = false
            tabContainer.addSubview(tab)
            tabButtons.append(tab)
        }
    }

    private func setupIndicator() {
        // Sliding indicator with gradient bg and accent border
        indicatorLayer.cornerRadius = 6
        indicatorLayer.borderWidth = 1
        indicatorLayer.borderColor = AppColors.accentBorder.cgColor
        indicatorLayer.backgroundColor = AppColors.accentGradientStart.cgColor
        indicatorLayer.shadowColor = AppColors.accent.cgColor
        indicatorLayer.shadowOpacity = 0.08
        indicatorLayer.shadowRadius = 4
        indicatorLayer.shadowOffset = CGSize(width: 0, height: 1)
        tabContainer.layer?.addSublayer(indicatorLayer)
    }

    private func setupViewToggle() {
        // View toggle container: same style as tab container
        viewToggleContainer.wantsLayer = true
        viewToggleContainer.layer?.backgroundColor = AppColors.whiteOverlay4.cgColor
        viewToggleContainer.layer?.cornerRadius = 8
        viewToggleContainer.layer?.borderWidth = 1
        viewToggleContainer.layer?.borderColor = AppColors.whiteOverlay4.cgColor
        viewToggleContainer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(viewToggleContainer)

        listToggle.translatesAutoresizingMaskIntoConstraints = false
        gridToggle.translatesAutoresizingMaskIntoConstraints = false
        viewToggleContainer.addSubview(listToggle)
        viewToggleContainer.addSubview(gridToggle)

        listToggle.target = self
        listToggle.action = #selector(listModeClicked)
        gridToggle.target = self
        gridToggle.action = #selector(gridModeClicked)

        updateViewToggleState()
    }

    private func setupBottomBorder() {
        bottomBorder.wantsLayer = true
        bottomBorder.layer?.backgroundColor = AppColors.whiteOverlay6.cgColor
        bottomBorder.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomBorder)
    }

    private func setupConstraints() {
        // Tab container - left side, centered vertically
        NSLayoutConstraint.activate([
            tabContainer.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            tabContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            tabContainer.heightAnchor.constraint(equalToConstant: 30),
        ])

        // Tab buttons inside container with 3px padding
        var previousTab: SegmentedTab?
        for tab in tabButtons {
            NSLayoutConstraint.activate([
                tab.centerYAnchor.constraint(equalTo: tabContainer.centerYAnchor),
                tab.heightAnchor.constraint(equalToConstant: 24),
            ])
            if let prev = previousTab {
                tab.leadingAnchor.constraint(equalTo: prev.trailingAnchor, constant: 1).isActive = true
            } else {
                tab.leadingAnchor.constraint(equalTo: tabContainer.leadingAnchor, constant: 3).isActive = true
            }
            previousTab = tab
        }
        if let lastTab = tabButtons.last {
            lastTab.trailingAnchor.constraint(equalTo: tabContainer.trailingAnchor, constant: -3).isActive = true
        }

        // View toggle container - right side
        NSLayoutConstraint.activate([
            viewToggleContainer.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            viewToggleContainer.centerYAnchor.constraint(equalTo: centerYAnchor),
            viewToggleContainer.heightAnchor.constraint(equalToConstant: 28),

            listToggle.leadingAnchor.constraint(equalTo: viewToggleContainer.leadingAnchor, constant: 3),
            listToggle.centerYAnchor.constraint(equalTo: viewToggleContainer.centerYAnchor),
            listToggle.widthAnchor.constraint(equalToConstant: 26),
            listToggle.heightAnchor.constraint(equalToConstant: 22),

            gridToggle.leadingAnchor.constraint(equalTo: listToggle.trailingAnchor, constant: 0),
            gridToggle.centerYAnchor.constraint(equalTo: viewToggleContainer.centerYAnchor),
            gridToggle.widthAnchor.constraint(equalToConstant: 26),
            gridToggle.heightAnchor.constraint(equalToConstant: 22),
            gridToggle.trailingAnchor.constraint(equalTo: viewToggleContainer.trailingAnchor, constant: -3),

            // Bottom border
            bottomBorder.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomBorder.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomBorder.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomBorder.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    override func layout() {
        super.layout()
        updateIndicatorPosition(animated: false)
    }

    // MARK: - Actions

    @objc private func tabClicked(_ sender: SegmentedTab) {
        guard let filter = sender.filter, filter != currentFilter else { return }
        currentFilter = filter
        updateTabAppearance()
        updateIndicatorPosition(animated: true)
        delegate?.tabBar(self, didSelectFilter: filter)
    }

    @objc private func listModeClicked() {
        guard currentViewMode != .list else { return }
        currentViewMode = .list
        updateViewToggleState()
        delegate?.tabBar(self, didChangeViewMode: .list)
    }

    @objc private func gridModeClicked() {
        guard currentViewMode != .grid else { return }
        currentViewMode = .grid
        updateViewToggleState()
        delegate?.tabBar(self, didChangeViewMode: .grid)
    }

    // MARK: - Public

    func setCurrentFilter(_ filter: ContentFilter) {
        guard filter != currentFilter else { return }
        currentFilter = filter
        updateTabAppearance()
        updateIndicatorPosition(animated: true)
    }

    func updateItemCounts(_ counts: [ContentFilter: Int]) {
        for tab in tabButtons {
            if let filter = tab.filter {
                tab.updateCount(counts[filter] ?? 0)
            }
        }
    }

    func setViewMode(_ mode: DesignSystem.ViewMode) {
        currentViewMode = mode
        updateViewToggleState()
    }

    func updateTabVisibility() {
        let settings = SettingsStore.shared
        var newHidden = Set<ContentFilter>()
        if !settings.captureImages { newHidden.insert(.images) }
        if !settings.captureText { newHidden.insert(.text) }
        if !settings.captureFiles { newHidden.insert(.files) }

        guard newHidden != hiddenFilters else { return }
        hiddenFilters = newHidden

        for tab in tabButtons {
            guard let filter = tab.filter else { continue }
            tab.isHidden = hiddenFilters.contains(filter)
        }

        // If the currently selected tab got hidden, fall back to All
        if hiddenFilters.contains(currentFilter) {
            currentFilter = .all
            updateTabAppearance()
            delegate?.tabBar(self, didSelectFilter: .all)
        }

        needsLayout = true
        layoutSubtreeIfNeeded()
        updateIndicatorPosition(animated: false)
    }

    // MARK: - Appearance

    private func updateTabAppearance() {
        for tab in tabButtons {
            tab.setActive(tab.filter == currentFilter)
        }
    }

    private func updateIndicatorPosition(animated: Bool) {
        guard let selectedIndex = ContentFilter.allCases.firstIndex(of: currentFilter),
              selectedIndex < tabButtons.count else { return }

        let selectedTab = tabButtons[selectedIndex]
        guard !selectedTab.isHidden else { return }

        // Need the tab's frame relative to the container
        let tabFrame = selectedTab.frame
        let indicatorFrame = CGRect(
            x: tabFrame.origin.x,
            y: 3,
            width: tabFrame.width,
            height: tabFrame.height
        )

        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.25)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            indicatorLayer.frame = indicatorFrame
            CATransaction.commit()
        } else {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            indicatorLayer.frame = indicatorFrame
            CATransaction.commit()
        }
    }

    private func updateViewToggleState() {
        listToggle.setActive(currentViewMode == .list)
        gridToggle.setActive(currentViewMode == .grid)
    }
}

// MARK: - Segmented Tab Button

class SegmentedTab: NSButton {
    let filter: ContentFilter?
    private let titleField = NSTextField()
    private let countField = NSTextField()
    private var isTabActive = false

    init(filter: ContentFilter) {
        self.filter = filter
        super.init(frame: .zero)
        setupTab()
    }

    required init?(coder: NSCoder) {
        self.filter = nil
        super.init(coder: coder)
    }

    private func setupTab() {
        guard let filter = filter else { return }

        // Clear button's built-in title so it doesn't overlap
        title = ""
        isBordered = false
        bezelStyle = .shadowlessSquare
        imagePosition = .noImage
        wantsLayer = true
        layer?.cornerRadius = 6

        // Custom title label
        titleField.stringValue = filter.rawValue
        titleField.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        titleField.textColor = AppColors.textTertiary
        titleField.isEditable = false
        titleField.isBordered = false
        titleField.drawsBackground = false
        titleField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleField)

        // Count label (right of title)
        countField.font = NSFont.systemFont(ofSize: 9, weight: .semibold)
        countField.textColor = AppColors.textDarkest
        countField.isEditable = false
        countField.isBordered = false
        countField.drawsBackground = false
        countField.isHidden = true
        countField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(countField)

        NSLayoutConstraint.activate([
            titleField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            titleField.centerYAnchor.constraint(equalTo: centerYAnchor),

            countField.leadingAnchor.constraint(equalTo: titleField.trailingAnchor, constant: 3),
            countField.centerYAnchor.constraint(equalTo: centerYAnchor),
            countField.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
        ])
    }

    func setActive(_ active: Bool) {
        isTabActive = active
        titleField.textColor = active ? AppColors.accentLavender : AppColors.textTertiary
        countField.textColor = active ? AppColors.accentLight : AppColors.textDarkest
    }

    func updateCount(_ count: Int) {
        if count > 0 {
            countField.stringValue = "\(count)"
            countField.isHidden = false
        } else {
            countField.isHidden = true
        }
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: NSSize {
        let titleSize = titleField.intrinsicContentSize
        let countSize = countField.isHidden ? NSSize.zero : countField.intrinsicContentSize
        let totalWidth = 10 + titleSize.width + (countField.isHidden ? 0 : 3 + countSize.width) + 8
        return NSSize(width: totalWidth, height: 24)
    }
}

// MARK: - View Toggle Button (22x26, matches V0 exactly)

class ViewToggleButton: NSButton {
    private var isToggleActive = false
    private let indicatorLayer = CALayer()

    init(symbolName: String, label: String) {
        super.init(frame: .zero)
        self.image = NSImage(systemSymbolName: symbolName, accessibilityDescription: label)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupButton() {
        isBordered = false
        bezelStyle = .shadowlessSquare
        imagePosition = .imageOnly
        wantsLayer = true
        layer?.cornerRadius = 6

        if let img = image {
            let config = NSImage.SymbolConfiguration(pointSize: 12.5, weight: .regular)
            self.image = img.withSymbolConfiguration(config)
        }

        contentTintColor = AppColors.textDim

        // Indicator background layer
        indicatorLayer.cornerRadius = 6
        indicatorLayer.borderWidth = 1
        indicatorLayer.borderColor = NSColor.clear.cgColor
        indicatorLayer.backgroundColor = NSColor.clear.cgColor
        layer?.insertSublayer(indicatorLayer, at: 0)
    }

    override func layout() {
        super.layout()
        indicatorLayer.frame = bounds
    }

    func setActive(_ active: Bool) {
        isToggleActive = active
        if active {
            indicatorLayer.backgroundColor = AppColors.accentGradientStart.cgColor
            indicatorLayer.borderColor = AppColors.accentBorder.cgColor
            indicatorLayer.shadowColor = AppColors.accent.cgColor
            indicatorLayer.shadowOpacity = 0.08
            indicatorLayer.shadowRadius = 4
            indicatorLayer.shadowOffset = CGSize(width: 0, height: 1)
            contentTintColor = AppColors.accentLavender
        } else {
            indicatorLayer.backgroundColor = NSColor.clear.cgColor
            indicatorLayer.borderColor = NSColor.clear.cgColor
            indicatorLayer.shadowOpacity = 0
            contentTintColor = AppColors.textDim
        }
    }
}
