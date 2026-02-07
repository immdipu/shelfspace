import Cocoa

// Flipped view so content starts at the top (macOS default is bottom-up)
private class FlippedView: NSView {
    override var isFlipped: Bool { true }
}

class SettingsPaneViewController: NSViewController {
    private let paneTitle: String
    private let paneSymbolName: String

    private let scrollView = NSScrollView()
    private let stackView = NSStackView()

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
        let container = FlippedView(frame: NSRect(x: 0, y: 0, width: 500, height: 400))
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
        // Document view (flipped so content flows top-to-bottom)
        let documentView = FlippedView()
        documentView.translatesAutoresizingMaskIntoConstraints = false

        // Stack view holds all sections
        stackView.orientation = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 24, bottom: 20, right: 24)
        documentView.addSubview(stackView)

        // Scroll view setup
        scrollView.drawsBackground = false
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.scrollerStyle = .overlay
        scrollView.borderType = .noBorder
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.documentView = documentView

        // Use the app's themed scroller
        let themedScroller = ThemedScroller()
        themedScroller.controlSize = .mini
        themedScroller.knobStyle = .light
        scrollView.verticalScroller = themedScroller
        scrollView.scrollerKnobStyle = .light
        scrollView.scrollerInsets = NSEdgeInsets(top: 4, left: 0, bottom: 4, right: 2)

        // Flipped clip view
        let clipView = FlippedClipView()
        clipView.drawsBackground = false
        scrollView.contentView = clipView
        scrollView.documentView = documentView

        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            // Scroll view fills parent
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            // Document view width matches scroll view
            documentView.leadingAnchor.constraint(equalTo: clipView.leadingAnchor),
            documentView.trailingAnchor.constraint(equalTo: clipView.trailingAnchor),
            documentView.topAnchor.constraint(equalTo: clipView.topAnchor),

            // Stack view fills document view
            stackView.topAnchor.constraint(equalTo: documentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: documentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: documentView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: documentView.bottomAnchor),
        ])
    }

    func addSection(_ section: NSView) {
        section.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(section)

        // Make each section stretch to full width of the stack
        section.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -48).isActive = true
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

        // Stack to hold rows
        let rowStack = NSStackView()
        rowStack.orientation = .vertical
        rowStack.spacing = 0
        rowStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(rowStack)

        // Add rows with separators
        for (index, row) in rows.enumerated() {
            let rowWrapper = NSView()
            rowWrapper.translatesAutoresizingMaskIntoConstraints = false

            row.translatesAutoresizingMaskIntoConstraints = false
            rowWrapper.addSubview(row)

            NSLayoutConstraint.activate([
                row.topAnchor.constraint(equalTo: rowWrapper.topAnchor, constant: 10),
                row.leadingAnchor.constraint(equalTo: rowWrapper.leadingAnchor, constant: 14),
                row.trailingAnchor.constraint(equalTo: rowWrapper.trailingAnchor, constant: -14),
                row.bottomAnchor.constraint(equalTo: rowWrapper.bottomAnchor, constant: -10),
            ])

            rowStack.addArrangedSubview(rowWrapper)

            // Separator between rows
            if index < rows.count - 1 {
                let sep = NSView()
                sep.wantsLayer = true
                sep.layer?.backgroundColor = AppColors.border.cgColor
                sep.translatesAutoresizingMaskIntoConstraints = false
                rowStack.addArrangedSubview(sep)
                sep.heightAnchor.constraint(equalToConstant: 1).isActive = true
            }
        }

        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: container.topAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 2),

            cardView.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 6),
            cardView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            rowStack.topAnchor.constraint(equalTo: cardView.topAnchor),
            rowStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            rowStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            rowStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
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

// Flipped clip view so scroll origin is at the top
private class FlippedClipView: NSClipView {
    override var isFlipped: Bool { true }
}
