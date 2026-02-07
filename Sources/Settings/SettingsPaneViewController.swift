import Cocoa

class SettingsPaneViewController: NSViewController {
    private let paneTitle: String
    private let paneSymbolName: String

    private let scrollView = NSScrollView()
    private let contentView = NSView()
    private var sectionViews: [NSView] = []

    init(title: String, symbolName: String) {
        self.paneTitle = title
        self.paneSymbolName = symbolName
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        let container = NSView(frame: NSRect(x: 0, y: 0, width: 500, height: 400))
        container.wantsLayer = true
        container.layer?.backgroundColor = AppColors.background.cgColor
        view = container
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = paneTitle
        setupScrollView()
    }

    private func setupScrollView() {
        // Scroll view setup
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        // Content view (flipped for top-to-bottom layout)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = contentView

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func addSection(_ section: NSView) {
        sectionViews.append(section)
        contentView.addSubview(section)
        layoutSections()
    }

    private func layoutSections() {
        let padding: CGFloat = 24
        let spacing: CGFloat = 16
        var currentY: CGFloat = padding

        for section in sectionViews {
            section.translatesAutoresizingMaskIntoConstraints = false

            // Remove old constraints
            section.removeFromSuperview()
            contentView.addSubview(section)

            NSLayoutConstraint.activate([
                section.topAnchor.constraint(equalTo: contentView.topAnchor, constant: currentY),
                section.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
                section.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            ])

            section.layoutSubtreeIfNeeded()
            let height = section.fittingSize.height
            currentY += height + spacing
        }

        // Update content view height
        let totalHeight = currentY + padding
        NSLayoutConstraint.activate([
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: totalHeight)
        ])
    }

    func makeSection(title: String, rows: [NSView]) -> NSView {
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false

        // Section header
        let headerLabel = NSTextField(labelWithString: title.uppercased())
        headerLabel.font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        headerLabel.textColor = AppColors.textTertiary
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(headerLabel)

        // Card background
        let cardView = NSView()
        cardView.wantsLayer = true
        cardView.layer?.backgroundColor = AppColors.cardBackground.cgColor
        cardView.layer?.cornerRadius = 10
        cardView.layer?.borderColor = AppColors.border.cgColor
        cardView.layer?.borderWidth = 1
        cardView.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(cardView)

        // Build rows
        var rowContainers: [NSView] = []
        for (index, row) in rows.enumerated() {
            let rowContainer = NSView()
            rowContainer.translatesAutoresizingMaskIntoConstraints = false

            row.translatesAutoresizingMaskIntoConstraints = false
            rowContainer.addSubview(row)

            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: rowContainer.topAnchor, constant: 10),
                row.leadingAnchor.constraint(equalTo: rowContainer.leadingAnchor, constant: 14),
                row.trailingAnchor.constraint(equalTo: rowContainer.trailingAnchor, constant: -14),
                row.bottomAnchor.constraint(equalTo: rowContainer.bottomAnchor, constant: -10),
            ])

            cardView.addSubview(rowContainer)
            rowContainers.append(rowContainer)

            // Add separator (except after last row)
            if index < rows.count - 1 {
                let separator = NSView()
                separator.wantsLayer = true
                separator.layer?.backgroundColor = AppColors.border.cgColor
                separator.translatesAutoresizingMaskIntoConstraints = false
                cardView.addSubview(separator)

                NSLayoutConstraint.activate([
                    separator.heightAnchor.constraint(equalToConstant: 1),
                    separator.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 14),
                    separator.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
                    separator.topAnchor.constraint(equalTo: rowContainer.bottomAnchor),
                ])
            }
        }

        // Layout row containers vertically
        for (index, rowContainer) in rowContainers.enumerated() {
            NSLayoutConstraint.activate([
                rowContainer.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
                rowContainer.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            ])

            if index == 0 {
                rowContainer.topAnchor.constraint(equalTo: cardView.topAnchor).isActive = true
            } else {
                rowContainer.topAnchor.constraint(equalTo: rowContainers[index - 1].bottomAnchor, constant: 1).isActive = true
            }

            if index == rowContainers.count - 1 {
                rowContainer.bottomAnchor.constraint(equalTo: cardView.bottomAnchor).isActive = true
            }
        }

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: container.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),

            cardView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
        ])

        return container
    }

    func makeRow(label: String, control: NSView) -> NSView {
        let row = NSView()
        row.translatesAutoresizingMaskIntoConstraints = false

        let labelView = NSTextField(labelWithString: label)
        labelView.font = NSFont.systemFont(ofSize: 13)
        labelView.textColor = AppColors.textPrimary
        labelView.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(labelView)

        control.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(control)

        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            control.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            control.centerYAnchor.constraint(equalTo: row.centerYAnchor),

            row.heightAnchor.constraint(greaterThanOrEqualToConstant: 22),
        ])

        return row
    }

    func makeParagraph(_ text: String) -> NSTextField {
        let label = NSTextField(wrappingLabelWithString: text)
        label.font = NSFont.systemFont(ofSize: 11)
        label.textColor = AppColors.textSecondary
        label.isSelectable = false
        return label
    }
}
