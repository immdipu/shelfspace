import Cocoa

final class AdvancedSettingsViewController: SettingsPaneViewController {
    init() {
        super.init(title: "Advanced", symbolName: "gearshape.2")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let actionsSection = makeSection(
            title: "Reset",
            rows: [
                makeActionRow(
                    title: "Reset all settings",
                    description: "Restore defaults and turn off Launch at Login",
                    buttonTitle: "Reset",
                    action: #selector(resetSettings)
                )
            ]
        )

        addSection(actionsSection)
    }

    private func makeActionRow(title: String, description: String, buttonTitle: String, action: Selector) -> NSView {
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

    @objc private func resetSettings() {
        let alert = NSAlert()
        alert.messageText = "Reset all settings?"
        alert.informativeText = "This will restore ShelfSpace preferences to their defaults."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Reset")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            SettingsStore.shared.resetToDefaults()
        }
    }
}
