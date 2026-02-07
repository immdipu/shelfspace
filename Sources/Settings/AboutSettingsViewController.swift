import Cocoa

final class AboutSettingsViewController: SettingsPaneViewController {
    init() {
        super.init(title: "About", symbolName: "info.circle")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        buildSections()
    }

    private func buildSections() {
        // App info card
        let appInfoView = makeAppInfoView()
        addSection(appInfoView)

        // Links section
        let linksSection = makeSection(
            title: "Links",
            rows: [
                makeLinkRow(title: "GitHub", description: "View source code", buttonTitle: "Open", action: #selector(openGitHub)),
                makeLinkRow(title: "Report Issue", description: "Found a bug?", buttonTitle: "Report", action: #selector(reportIssue))
            ]
        )
        addSection(linksSection)
    }

    private func makeAppInfoView() -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Card background
        let cardView = NSView()
        cardView.wantsLayer = true
        cardView.layer?.backgroundColor = AppColors.cardBackground.cgColor
        cardView.layer?.cornerRadius = 10
        cardView.layer?.borderColor = AppColors.border.cgColor
        cardView.layer?.borderWidth = 1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(cardView)

        // App icon
        let iconView = NSImageView()
        if let appIcon = NSImage(named: NSImage.applicationIconName) {
            iconView.image = appIcon
        }
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconView)

        // App name
        let titleLabel = NSTextField(labelWithString: AppDelegate.appName)
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = AppColors.textPrimary
        titleLabel.alignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(titleLabel)

        // Version
        let versionLabel = NSTextField(labelWithString: "Version \(AppDelegate.appVersion) (\(AppDelegate.buildNumber))")
        versionLabel.font = NSFont.systemFont(ofSize: 11)
        versionLabel.textColor = AppColors.textSecondary
        versionLabel.alignment = .center
        versionLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(versionLabel)

        // Copyright
        let copyrightLabel = NSTextField(labelWithString: AppDelegate.copyright)
        copyrightLabel.font = NSFont.systemFont(ofSize: 10)
        copyrightLabel.textColor = AppColors.textTertiary
        copyrightLabel.alignment = .center
        copyrightLabel.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(copyrightLabel)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: container.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            iconView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            iconView.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            iconView.widthAnchor.constraint(equalToConstant: 64),
            iconView.heightAnchor.constraint(equalToConstant: 64),

            titleLabel.topAnchor.constraint(equalTo: iconView.bottomAnchor, constant: 10),
            titleLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            versionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            versionLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),

            copyrightLabel.topAnchor.constraint(equalTo: versionLabel.bottomAnchor, constant: 6),
            copyrightLabel.centerXAnchor.constraint(equalTo: cardView.centerXAnchor),
            copyrightLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20),
        ])

        return container
    }

    private func makeLinkRow(title: String, description: String, buttonTitle: String, action: Selector) -> NSView {
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
