import Cocoa

/// Protocol for settings view delegate
protocol SettingsViewDelegate: AnyObject {
    func settingsViewDidClose(_ settingsView: SettingsView)
    func settingsViewDidChangeDensity(_ settingsView: SettingsView, density: DesignSystem.CardSize)
}

/// Settings panel view
class SettingsView: NSView {
    // MARK: - Properties

    weak var delegate: SettingsViewDelegate?

    private let titleLabel = NSTextField()
    private let closeButton = ActionButton(symbolName: "xmark", accessibilityLabel: "Close")
    private let scrollView = NSScrollView()
    private let contentStack = NSStackView()

    // MARK: - Initialization

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        wantsLayer = true
        layer?.backgroundColor = AppColors.backgroundSecondary.cgColor
        layer?.cornerRadius = DesignSystem.CornerRadius.lg

        setupHeader()
        setupScrollView()
        setupSections()
        setupConstraints()
    }

    // MARK: - Setup

    private func setupHeader() {
        titleLabel.stringValue = "Settings"
        titleLabel.font = DesignSystem.Typography.title
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.target = self
        closeButton.action = #selector(closeClicked)
        addSubview(closeButton)
    }

    private func setupScrollView() {
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.drawsBackground = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        contentStack.orientation = .vertical
        contentStack.alignment = .leading
        contentStack.spacing = DesignSystem.Spacing.xl
        contentStack.translatesAutoresizingMaskIntoConstraints = false

        scrollView.documentView = contentStack
    }

    private func setupSections() {
        // Appearance section
        let appearanceSection = createSection(
            title: "Appearance",
            content: createAppearanceContent()
        )
        contentStack.addArrangedSubview(appearanceSection)

        // Storage section
        let storageSection = createSection(
            title: "Storage",
            content: createStorageContent()
        )
        contentStack.addArrangedSubview(storageSection)

        // About section
        let aboutSection = createSection(
            title: "About",
            content: createAboutContent()
        )
        contentStack.addArrangedSubview(aboutSection)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Title
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.lg),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.lg),

            // Close button
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: DesignSystem.Spacing.lg),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.lg),
            closeButton.widthAnchor.constraint(equalToConstant: 24),
            closeButton.heightAnchor.constraint(equalToConstant: 24),

            // Scroll view
            scrollView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.xl),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: DesignSystem.Spacing.lg),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -DesignSystem.Spacing.lg),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -DesignSystem.Spacing.lg),

            // Content stack
            contentStack.topAnchor.constraint(equalTo: scrollView.contentView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.contentView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.contentView.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }

    // MARK: - Section Creation

    private func createSection(title: String, content: NSView) -> NSView {
        let container = NSView()
        container.wantsLayer = true
        container.layer?.backgroundColor = AppColors.backgroundTertiary.cgColor
        container.layer?.cornerRadius = DesignSystem.CornerRadius.md
        container.translatesAutoresizingMaskIntoConstraints = false

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = DesignSystem.Typography.subtitle
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(titleLabel)

        content.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(content)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: DesignSystem.Spacing.md),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: DesignSystem.Spacing.md),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -DesignSystem.Spacing.md),

            content.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: DesignSystem.Spacing.md),
            content.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: DesignSystem.Spacing.md),
            content.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -DesignSystem.Spacing.md),
            content.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -DesignSystem.Spacing.md),

            container.widthAnchor.constraint(greaterThanOrEqualToConstant: 300)
        ])

        return container
    }

    private func createAppearanceContent() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = DesignSystem.Spacing.md

        // Grid density row
        let densityRow = createSettingRow(
            label: "Grid Density",
            control: createDensitySegmentedControl()
        )
        stack.addArrangedSubview(densityRow)

        // Launch at login row
        let launchRow = createSettingRow(
            label: "Launch at Login",
            control: createToggle(isOn: false, action: #selector(launchAtLoginToggled(_:)))
        )
        stack.addArrangedSubview(launchRow)

        return stack
    }

    private func createStorageContent() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = DesignSystem.Spacing.md

        // Max items row
        let maxItemsRow = createSettingRow(
            label: "Max Items",
            control: createPopUpButton(options: ["25", "50", "100"], selectedIndex: 1)
        )
        stack.addArrangedSubview(maxItemsRow)

        // Auto-clear row
        let autoClearRow = createSettingRow(
            label: "Auto-clear unpinned after",
            control: createPopUpButton(options: ["Never", "1 day", "7 days", "30 days"], selectedIndex: 0)
        )
        stack.addArrangedSubview(autoClearRow)

        // Storage used row
        let storageLabel = NSTextField(labelWithString: "Storage Used: --")
        storageLabel.font = DesignSystem.Typography.caption
        storageLabel.textColor = AppColors.textSecondary

        let clearCacheButton = ToolbarButton(title: "Clear Cache", symbolName: "trash")
        clearCacheButton.target = self
        clearCacheButton.action = #selector(clearCacheClicked)

        let storageRow = NSStackView(views: [storageLabel, clearCacheButton])
        storageRow.distribution = .equalSpacing
        stack.addArrangedSubview(storageRow)

        return stack
    }

    private func createAboutContent() -> NSView {
        let stack = NSStackView()
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = DesignSystem.Spacing.sm

        let versionLabel = NSTextField(labelWithString: "ShelfSpace v\(AppDelegate.appVersion)")
        versionLabel.font = DesignSystem.Typography.body
        versionLabel.textColor = AppColors.textPrimary
        stack.addArrangedSubview(versionLabel)

        let copyrightLabel = NSTextField(labelWithString: AppDelegate.copyright)
        copyrightLabel.font = DesignSystem.Typography.caption
        copyrightLabel.textColor = AppColors.textSecondary
        stack.addArrangedSubview(copyrightLabel)

        let buttonStack = NSStackView()
        buttonStack.spacing = DesignSystem.Spacing.sm

        let githubButton = ToolbarButton(title: "GitHub", symbolName: "link")
        githubButton.target = self
        githubButton.action = #selector(openGitHub)
        buttonStack.addArrangedSubview(githubButton)

        let issueButton = ToolbarButton(title: "Report Issue", symbolName: "exclamationmark.bubble")
        issueButton.target = self
        issueButton.action = #selector(reportIssue)
        buttonStack.addArrangedSubview(issueButton)

        stack.addArrangedSubview(buttonStack)

        return stack
    }

    // MARK: - Control Creation

    private func createSettingRow(label: String, control: NSView) -> NSView {
        let labelView = NSTextField(labelWithString: label)
        labelView.font = DesignSystem.Typography.body
        labelView.textColor = AppColors.textSecondary

        let stack = NSStackView(views: [labelView, control])
        stack.distribution = .equalSpacing

        NSLayoutConstraint.activate([
            stack.widthAnchor.constraint(greaterThanOrEqualToConstant: 280)
        ])

        return stack
    }

    private func createDensitySegmentedControl() -> NSSegmentedControl {
        let control = NSSegmentedControl(labels: ["Compact", "Comfortable", "Large"], trackingMode: .selectOne, target: self, action: #selector(densityChanged(_:)))

        let currentDensity = GridDensityManager.shared.currentDensity
        switch currentDensity {
        case .compact: control.selectedSegment = 0
        case .comfortable: control.selectedSegment = 1
        case .large: control.selectedSegment = 2
        }

        return control
    }

    private func createToggle(isOn: Bool, action: Selector) -> NSSwitch {
        let toggle = NSSwitch()
        toggle.state = isOn ? .on : .off
        toggle.target = self
        toggle.action = action
        return toggle
    }

    private func createPopUpButton(options: [String], selectedIndex: Int) -> NSPopUpButton {
        let popup = NSPopUpButton()
        popup.addItems(withTitles: options)
        popup.selectItem(at: selectedIndex)
        return popup
    }

    // MARK: - Actions

    @objc private func closeClicked() {
        delegate?.settingsViewDidClose(self)
    }

    @objc private func densityChanged(_ sender: NSSegmentedControl) {
        let densities: [DesignSystem.CardSize] = [.compact, .comfortable, .large]
        let newDensity = densities[sender.selectedSegment]
        GridDensityManager.shared.currentDensity = newDensity
        delegate?.settingsViewDidChangeDensity(self, density: newDensity)
    }

    @objc private func launchAtLoginToggled(_ sender: NSSwitch) {
        // TODO: Implement launch at login
    }

    @objc private func clearCacheClicked() {
        // TODO: Implement cache clearing
    }

    @objc private func openGitHub() {
        if let url = URL(string: "https://github.com/immdipu") {
            NSWorkspace.shared.open(url)
        }
    }

    @objc private func reportIssue() {
        if let url = URL(string: "https://github.com/immdipu/ShelfSpace/issues") {
            NSWorkspace.shared.open(url)
        }
    }
}
