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

        // App icon - custom ShelfSpace logo
        let iconView = NSView()
        iconView.wantsLayer = true
        iconView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconView)
        drawShelfSpaceLogo(in: iconView, size: 64)

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

    private func drawShelfSpaceLogo(in container: NSView, size: CGFloat) {
        let gradient = CAGradientLayer()
        gradient.colors = [
            NSColor(red: 0x8B/255.0, green: 0x5C/255.0, blue: 0xF6/255.0, alpha: 1.0).cgColor,
            NSColor(red: 0x7C/255.0, green: 0x3A/255.0, blue: 0xED/255.0, alpha: 1.0).cgColor,
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.frame = CGRect(x: 0, y: 0, width: size, height: size)
        gradient.cornerRadius = size * 0.22

        container.layer?.addSublayer(gradient)

        // Three white bars (bottom-up since AppKit is flipped in layers)
        let barSpecs: [(yFraction: CGFloat, widthFraction: CGFloat, opacity: Float)] = [
            (0.62, 0.64, 0.95),  // top bar (longest)
            (0.44, 0.44, 0.70),  // middle bar
            (0.26, 0.54, 0.45),  // bottom bar (medium)
        ]

        for spec in barSpecs {
            let bar = CALayer()
            let barW = size * spec.widthFraction
            let barH = size * 0.13
            let barX = size * 0.18
            // Flip Y for Core Animation (origin is bottom-left)
            let barY = size - (size * spec.yFraction) - barH
            bar.frame = CGRect(x: barX, y: barY, width: barW, height: barH)
            bar.backgroundColor = NSColor.white.cgColor
            bar.cornerRadius = barH * 0.31
            bar.opacity = spec.opacity
            gradient.addSublayer(bar)
        }
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
