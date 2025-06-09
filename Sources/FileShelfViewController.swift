import Cocoa

enum ContentFilter: String, CaseIterable {
    case all = "All"
    case images = "Images"
    case text = "Text"
    case files = "Files"
    
    var iconName: String {
        switch self {
        case .all: return "tray.2"
        case .images: return "photo"
        case .text: return "doc.text"
        case .files: return "doc"
        }
    }
}

// MARK: - Simple 3-Column Layout
class Simple3ColumnLayout: NSCollectionViewLayout {
    private let itemSize = NSSize(width: 120, height: 140)
    private let itemsPerRow = 3
    private let verticalSpacing: CGFloat = 16
    private let topBottomMargin: CGFloat = 16
    
    private var itemAttributes: [NSCollectionViewLayoutAttributes] = []
    private var contentSize = NSSize.zero
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        
        itemAttributes.removeAll()
        
        let numberOfItems = collectionView.numberOfItems(inSection: 0)
        if numberOfItems == 0 {
            contentSize = NSSize.zero
            return
        }
        
        // Calculate horizontal spacing for exactly 3 items per row
        let availableWidth = collectionView.bounds.width
        let totalItemWidth = CGFloat(itemsPerRow) * itemSize.width  // 3 * 120 = 360
        let remainingSpace = availableWidth - totalItemWidth
        let horizontalSpacing = remainingSpace / 4  // left + gap1 + gap2 + right
        
        print("3-Column Layout: availableWidth=\(availableWidth), horizontalSpacing=\(horizontalSpacing)")
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let attributes = NSCollectionViewLayoutAttributes(forItemWith: indexPath)
            
            let row = item / itemsPerRow
            let col = item % itemsPerRow
            
            let x = horizontalSpacing + CGFloat(col) * (itemSize.width + horizontalSpacing)
            let y = topBottomMargin + CGFloat(row) * (itemSize.height + verticalSpacing)
            
            attributes.frame = NSRect(
                x: x,
                y: y,
                width: itemSize.width,
                height: itemSize.height
            )
            
            itemAttributes.append(attributes)
        }
        
        let numberOfRows = (numberOfItems + itemsPerRow - 1) / itemsPerRow
        contentSize = NSSize(
            width: collectionView.bounds.width,
            height: topBottomMargin + CGFloat(numberOfRows) * itemSize.height + CGFloat(max(0, numberOfRows - 1)) * verticalSpacing + topBottomMargin
        )
    }
    
    override var collectionViewContentSize: NSSize {
        return contentSize
    }
    
    override func layoutAttributesForElements(in rect: NSRect) -> [NSCollectionViewLayoutAttributes] {
        return itemAttributes.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> NSCollectionViewLayoutAttributes? {
        guard indexPath.item < itemAttributes.count else { return nil }
        return itemAttributes[indexPath.item]
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: NSRect) -> Bool {
        return newBounds.width != collectionView?.bounds.width
    }
}

class FileShelfViewController: NSViewController {
    private var scrollView: NSScrollView!
    private var collectionView: NSCollectionView!
    private var dropZoneView: DropZoneView!
    private var headerView: NSView!
    private var tabsContainer: NSView!
    private var tabButtons: [NSButton] = []
    private var tabIndicator: NSView! // For sliding tab background
    private var currentFilter: ContentFilter = .all
    private var statusLabel: NSTextField!
    private var clearAllButton: NSButton!
    private var aboutButton: NSButton!
    private var quitButton: NSButton!
    
    private var items: [FileShelfItem] = []
    private var filteredItems: [FileShelfItem] = []
    private let maxItems = 50
    private let tempDirectory: URL
    
    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        // Create temp directory
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ShelfSpace")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        self.tempDirectory = tempDir
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        // Create temp directory
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ShelfSpace")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        self.tempDirectory = tempDir
        
        super.init(coder: coder)
    }
    
    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 600))
        setupUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("=== VIEW DID LOAD ===")
        print("Items count at viewDidLoad: \(items.count)")
        for (index, item) in items.enumerated() {
            print("  \(index): \(item.displayName) (\(item.itemType))")
        }
        
        setupCollectionView()
        
        print("CollectionView setup complete. CollectionView: \(collectionView != nil ? "EXISTS" : "NIL")")
        print("ScrollView: \(scrollView != nil ? "EXISTS" : "NIL")")
        
        // Update content now that the view is loaded
        updateContent()
        
        // Update tab appearance after view is loaded
        DispatchQueue.main.async {
            self.updateTabAppearance()
            print("Initial tab appearance updated")
        }
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        updateTabAppearance()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        print("=== VIEW DID APPEAR ===")
        print("Items count at viewDidAppear: \(items.count)")
        
        // Force refresh content in case items were added before view was ready
        if !items.isEmpty {
            print("Forcing content update because we have \(items.count) items")
            updateContent()
        }
    }
    
    private func setupUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = AppColors.background.cgColor
        
        setupHeader()
        setupTabs()
        setupDropZone()
        setupCollectionView()
        setupConstraints()
    }
    
    private func setupHeader() {
        headerView = NSView()
        headerView.wantsLayer = true
        headerView.layer?.backgroundColor = AppColors.primary.withAlphaComponent(0.1).cgColor
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
        
        // App title with signature color
        let titleLabel = NSTextField(labelWithString: "ShelfSpace")
        titleLabel.font = NSFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = AppColors.primary
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLabel)
        
        // Status label
        statusLabel = NSTextField(labelWithString: "Ready")
        statusLabel.font = NSFont.systemFont(ofSize: 11)
        statusLabel.textColor = AppColors.secondaryText
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(statusLabel)
        
        // Quit button
        quitButton = NSButton()
        quitButton.image = NSImage(systemSymbolName: "xmark.circle", accessibilityDescription: "Quit")
        quitButton.isBordered = false
        quitButton.bezelStyle = .shadowlessSquare
        quitButton.target = self
        quitButton.action = #selector(quitApp)
        quitButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(quitButton)
        
        // About button - Changed from ⚡️ to a better icon
        aboutButton = NSButton()
        aboutButton.image = NSImage(systemSymbolName: "info.circle", accessibilityDescription: "About")
        aboutButton.isBordered = false
        aboutButton.bezelStyle = .shadowlessSquare
        aboutButton.target = self
        aboutButton.action = #selector(showAbout)
        aboutButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(aboutButton)
        
        // Test button for debugging
        let testButton = NSButton(title: "Test", target: self, action: #selector(addTestItem))
        testButton.bezelStyle = .rounded
        testButton.font = NSFont.systemFont(ofSize: 11)
        testButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(testButton)
        
        // Clear all button
        clearAllButton = NSButton(title: "Clear", target: self, action: #selector(clearAllItems))
        clearAllButton.bezelStyle = .rounded
        clearAllButton.font = NSFont.systemFont(ofSize: 11)
        clearAllButton.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(clearAllButton)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 12),
            
            quitButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            quitButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            quitButton.widthAnchor.constraint(equalToConstant: 32),
            quitButton.heightAnchor.constraint(equalToConstant: 32),
            
            aboutButton.trailingAnchor.constraint(equalTo: quitButton.leadingAnchor, constant: -8),
            aboutButton.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            aboutButton.widthAnchor.constraint(equalToConstant: 32),
            aboutButton.heightAnchor.constraint(equalToConstant: 32),
            
            testButton.trailingAnchor.constraint(equalTo: aboutButton.leadingAnchor, constant: -8),
            testButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            clearAllButton.trailingAnchor.constraint(equalTo: testButton.leadingAnchor, constant: -8),
            clearAllButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            statusLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            statusLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2)
        ])
    }
    
    private func setupTabs() {
        tabsContainer = NSView()
        tabsContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabsContainer)
        
        // Tab indicator (sliding background)
        tabIndicator = NSView()
        tabIndicator.wantsLayer = true
        tabIndicator.layer?.backgroundColor = AppColors.primary.cgColor
        tabIndicator.layer?.cornerRadius = 6
        tabIndicator.translatesAutoresizingMaskIntoConstraints = false
        tabsContainer.addSubview(tabIndicator)
        
        var previousButton: NSButton?
        
        for filter in ContentFilter.allCases {
            let button = createTabButton(for: filter)
            tabsContainer.addSubview(button)
            tabButtons.append(button)
            
            NSLayoutConstraint.activate([
                button.topAnchor.constraint(equalTo: tabsContainer.topAnchor, constant: 8),
                button.bottomAnchor.constraint(equalTo: tabsContainer.bottomAnchor, constant: -8),
                button.widthAnchor.constraint(equalToConstant: 90)
            ])
            
            if let previous = previousButton {
                button.leadingAnchor.constraint(equalTo: previous.trailingAnchor, constant: 4).isActive = true
            } else {
                button.leadingAnchor.constraint(equalTo: tabsContainer.leadingAnchor, constant: 16).isActive = true
            }
            
            previousButton = button
        }
        
        updateTabAppearance()
    }
    
    private func createTabButton(for filter: ContentFilter) -> NSButton {
        let button = NSButton(title: filter.rawValue, target: self, action: #selector(tabButtonClicked(_:)))
        button.tag = ContentFilter.allCases.firstIndex(of: filter) ?? 0
        button.isBordered = false
        button.font = NSFont.systemFont(ofSize: 11, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.wantsLayer = true
        button.layer?.cornerRadius = 6
        
        return button
    }
    
    private func setupDropZone() {
        dropZoneView = DropZoneView()
        dropZoneView.delegate = self
        dropZoneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dropZoneView)
    }
    
    private func setupCollectionView() {
        // Prevent multiple setups
        if scrollView != nil && collectionView != nil {
            print("Collection view already set up, skipping...")
            return
        }
        
        print("Setting up collection view...")
        
        // Setup collection view
        collectionView = NSCollectionView()
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        // Disable animations completely
        collectionView.wantsLayer = true
        collectionView.layer?.actions = ["contents": NSNull(), "sublayers": NSNull(), "frame": NSNull(), "bounds": NSNull(), "position": NSNull()]
        // Remove explicit registration - we'll create cells manually in itemForRepresentedObjectAt
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Setup scroll view
        scrollView = NSScrollView()
        scrollView.documentView = collectionView
        scrollView.hasVerticalScroller = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup layout
        let layout = Simple3ColumnLayout()
        
        collectionView.collectionViewLayout = layout
        
        print("Collection view setup complete:")
        print("  - CollectionView: \(collectionView)")
        print("  - ScrollView: \(scrollView)")
        print("  - Layout: \(layout)")
        print("  - DataSource: \(collectionView.dataSource != nil ? "SET" : "NIL")")
        print("  - Delegate: \(collectionView.delegate != nil ? "SET" : "NIL")")
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            // Header
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 60),
            
            // Tabs
            tabsContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tabsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabsContainer.heightAnchor.constraint(equalToConstant: 44),
            
            // Drop zone
            dropZoneView.topAnchor.constraint(equalTo: tabsContainer.bottomAnchor, constant: 12),
            dropZoneView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dropZoneView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dropZoneView.heightAnchor.constraint(equalToConstant: 80),
            
            // ScrollView - anchor to tabs with small gap when drop zone is hidden
            scrollView.topAnchor.constraint(equalTo: tabsContainer.bottomAnchor, constant: 12),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            // Force minimum dimensions
            scrollView.widthAnchor.constraint(greaterThanOrEqualToConstant: 300),
            scrollView.heightAnchor.constraint(greaterThanOrEqualToConstant: 200)
        ])
        
        // Force immediate layout to resolve constraints
        view.layoutSubtreeIfNeeded()
        
        // Debug constraints
        print("Constraints applied for scrollView:")
        print("  - Top: \(scrollView.topAnchor)")
        print("  - Leading: \(scrollView.leadingAnchor)")
        print("  - Trailing: \(scrollView.trailingAnchor)")
        print("  - Bottom: \(scrollView.bottomAnchor)")
        print("After layout - ScrollView frame: \(scrollView.frame)")
    }
    
    @objc private func tabButtonClicked(_ sender: NSButton) {
        let newFilter = ContentFilter.allCases[sender.tag]
        guard newFilter != currentFilter else { return }
        
        currentFilter = newFilter
        updateTabAppearance()
        updateContent()
    }
    
    private func updateTabAppearance() {
        let selectedIndex = ContentFilter.allCases.firstIndex(of: currentFilter) ?? 0
        let selectedButton = tabButtons[selectedIndex]
        
        // Animate tab indicator to selected button position
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            
            // Move tab indicator behind selected button
            tabIndicator.animator().frame = CGRect(
                x: selectedButton.frame.origin.x,
                y: selectedButton.frame.origin.y,
                width: selectedButton.frame.width,
                height: selectedButton.frame.height
            )
        }
        
        // Update button text colors
        for (index, button) in tabButtons.enumerated() {
            let isSelected = index == selectedIndex
            button.contentTintColor = isSelected ? NSColor.white : AppColors.secondaryText
        }
    }
    
    private func updateContent() {
        // Ensure view is loaded before updating UI components
        guard isViewLoaded, collectionView != nil else { 
            print("FileShelfViewController: updateContent - view not loaded or collectionView is nil")
            return 
        }
        
        print("=== FILTERING DEBUG ===")
        print("Total items before filtering: \(items.count)")
        print("Current filter: \(currentFilter)")
        
        for (index, item) in items.enumerated() {
            print("  \(index): \(item.displayName) - isImage:\(item.isImage) isText:\(item.isText) type:\(item.itemType)")
        }
        
        filteredItems = items.filter { item in
            let shouldInclude: Bool
            switch currentFilter {
            case .all:
                shouldInclude = true
            case .images:
                shouldInclude = item.isImage
            case .text:
                shouldInclude = item.isText
            case .files:
                shouldInclude = !item.isImage && !item.isText
            }
            print("  Item '\(item.displayName)' (\(item.itemType)) - filter '\(currentFilter)' -> \(shouldInclude ? "INCLUDE" : "EXCLUDE")")
            return shouldInclude
        }
        
        print("Items after filtering: \(filteredItems.count)")
        print("=== END FILTERING DEBUG ===")
        
        
        print("FileShelfViewController: updateContent - filtered \(filteredItems.count) items for filter \(currentFilter)")
        
        DispatchQueue.main.async {
            // Disable all animations for collection view updates
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.collectionView.reloadData()
            CATransaction.commit()
            
            self.updateStatusLabel()
            self.updateDropZoneVisibility()
            
            // Debug frame sizes
            print("=== UI FRAME DEBUG ===")
            print("View frame: \(self.view.frame)")
            print("ScrollView frame: \(self.scrollView.frame)")
            print("CollectionView frame: \(self.collectionView.frame)")
            print("CollectionView bounds: \(self.collectionView.bounds)")
            print("CollectionView visible rect: \(self.collectionView.visibleRect)")
            print("CollectionView number of sections: \(self.collectionView.numberOfSections)")
            if self.collectionView.numberOfSections > 0 {
                print("CollectionView items in section 0: \(self.collectionView.numberOfItems(inSection: 0))")
            }
            print("=== END FRAME DEBUG ===")
            
            print("FileShelfViewController: UI updated on main queue")
        }
    }
    
    private func updateDropZoneVisibility() {
        guard isViewLoaded, dropZoneView != nil, collectionView != nil else { return }
        
        let shouldShowDropZone = items.isEmpty
        
        // When the drop zone is hidden, no additional spacing is needed.
        // When shown, we don't adjust collection view insets as it doesn't support contentInsets.
        // Simply hide/show the drop zone without adjusting collection view spacing.
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.allowsImplicitAnimation = true
            
            self.dropZoneView.isHidden = !shouldShowDropZone
            
            self.view.layoutSubtreeIfNeeded()
        }
    }
    
    private func updateStatusLabel() {
        guard isViewLoaded, statusLabel != nil else { return }
        
        let totalCount = items.count
        let filteredCount = filteredItems.count
        
        if totalCount == 0 {
            statusLabel.stringValue = "Ready - Drop files or copy content"
        } else if currentFilter == .all {
            statusLabel.stringValue = "\(totalCount) items"
        } else {
            statusLabel.stringValue = "\(filteredCount) of \(totalCount) items"
        }
    }
    
    @objc private func showAbout() {
        let alert = NSAlert()
        alert.messageText = "ShelfSpace"
        alert.informativeText = """
        A lightweight temporary file and clipboard manager for macOS.
        
        Features:
        • Drag & drop files up to 200MB
        • Automatic screenshot detection
        • Copy/paste text and images
        • Smart file categorization
        • Pin important items
        
        Created by Dipu
        """
        
        alert.addButton(withTitle: "Visit GitHub")
        alert.addButton(withTitle: "OK")
        
        alert.alertStyle = .informational
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Open GitHub profile
            NSWorkspace.shared.open(URL(string: "https://github.com/immdipu")!)
        }
    }
    
    func addItems(_ newItems: [FileShelfItem]) {
        print("FileShelfViewController: Adding \(newItems.count) items")
        
        items.insert(contentsOf: newItems, at: 0)
        
        // Enforce max items limit
        if items.count > maxItems {
            let itemsToRemove = Array(items.suffix(from: maxItems))
            items.removeLast(itemsToRemove.count)
            for item in itemsToRemove {
                item.cleanup()
            }
        }
        
        print("FileShelfViewController: Total items now: \(items.count)")
        
        if isViewLoaded {
            updateContent()
        }
    }
    
    func removeItem(_ item: FileShelfItem) {
        item.cleanup()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            if let filteredIndex = filteredItems.firstIndex(where: { $0.id == item.id }) {
                filteredItems.remove(at: filteredIndex)
                collectionView.deleteItems(at: [IndexPath(item: filteredIndex, section: 0)])
            }
        }
        updateStatusLabel()
        updateDropZoneVisibility()
    }
    
    @objc private func clearAllItems() {
        let unpinnedItems = items.filter { !$0.isPinned }
        for item in unpinnedItems {
            item.cleanup()
        }
        items.removeAll { !$0.isPinned }
        updateContent()
    }
    
    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }
    
    @objc private func addTestItem() {
        print("=== MANUAL TEST: Adding test items ===")
        
        let testItems = [
            FileShelfItem(textContent: "Test text content for debugging UI", origin: .clipboard),
            FileShelfItem(textContent: "Another test item to verify collection view", origin: .clipboard)
        ]
        
        print("Manual test: Created \(testItems.count) test items")
        addItems(testItems)
    }
}

// MARK: - Collection View Data Source
extension FileShelfViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        print("CollectionView: numberOfSections = 1")
        return 1
    }
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        print("CollectionView: numberOfItemsInSection = \(filteredItems.count) (section: \(section))")
        return filteredItems.count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        print("CollectionView: creating cell for item \(indexPath.item) in section \(indexPath.section)")
        
        // Create FileShelfItemCell directly without registration
        let cell = FileShelfItemCell()
        let item = filteredItems[indexPath.item]
        
        print("CollectionView: configuring cell with item: \(item.displayName) (type: \(item.itemType))")
        cell.configure(with: item, delegate: self)
        
        return cell
    }
}

// MARK: - Collection View Delegate
extension FileShelfViewController: NSCollectionViewDelegate {
    func collectionView(_ collectionView: NSCollectionView, canDragItemsAt indexPaths: Set<IndexPath>, with event: NSEvent) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: NSCollectionView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forItemsAt indexPaths: Set<IndexPath>) {
        session.animatesToStartingPositionsOnCancelOrFail = true
        
        var draggingItems: [NSDraggingItem] = []
        for indexPath in indexPaths {
            let item = filteredItems[indexPath.item]
            if let draggingItem = item.createDraggingItem() {
                draggingItems.append(draggingItem)
            }
        }
        
        session.enumerateDraggingItems(options: [], for: nil, classes: [NSPasteboardItem.self], searchOptions: [:]) { (draggingItem, idx, stop) in
            if idx < draggingItems.count {
                draggingItem.setDraggingFrame(draggingItems[idx].draggingFrame, contents: draggingItems[idx].item)
            }
        }
    }
}

// MARK: - Drop Zone Delegate
extension FileShelfViewController: DropZoneViewDelegate {
    func dropZoneView(_ dropZoneView: DropZoneView, didReceiveFiles urls: [URL]) {
        var newItems: [FileShelfItem] = []
        
        for url in urls {
            if let item = createItemFromDroppedURL(url) {
                newItems.append(item)
            }
        }
        
        if !newItems.isEmpty {
            addItems(newItems)
        }
    }
    
    private func createItemFromDroppedURL(_ url: URL) -> FileShelfItem? {
        guard url.isFileURL else { return nil }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            
            // Check file size limit (200 MB)
            let maxFileSize: Int64 = 200 * 1024 * 1024
            guard fileSize <= maxFileSize else {
                // Show size limit warning
                DispatchQueue.main.async {
                    let alert = NSAlert()
                    alert.messageText = "File Too Large"
                    alert.informativeText = "Files must be smaller than 200 MB. This file is \(ByteCountFormatter().string(fromByteCount: fileSize))."
                    alert.runModal()
                }
                return nil
            }
            
            let mimeType = url.mimeType
            
            // Copy file to temp directory
            let filename = url.lastPathComponent
            let tempURL = tempDirectory.appendingPathComponent(filename)
            
            // Generate unique filename if file already exists
            var finalURL = tempURL
            var counter = 1
            while FileManager.default.fileExists(atPath: finalURL.path) {
                let name = url.deletingPathExtension().lastPathComponent
                let ext = url.pathExtension
                let newName = "\(name)_\(counter).\(ext)"
                finalURL = tempDirectory.appendingPathComponent(newName)
                counter += 1
            }
            
            try FileManager.default.copyItem(at: url, to: finalURL)
            
            return FileShelfItem(originalName: filename, fileURL: finalURL, mimeType: mimeType, fileSize: fileSize, origin: .dragDrop)
        } catch {
            print("Failed to process dropped file: \(error)")
            return nil
        }
    }
}

// MARK: - File Shelf Item Cell Delegate
extension FileShelfViewController: FileShelfItemCellDelegate {
    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestCopyItem item: FileShelfItem) {
        // Tell clipboard monitor to ignore the next change since we're copying
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            appDelegate.clipboardMonitor.ignoreNextClipboardChange()
        }
        
        item.copyToClipboard()
        
        // Show brief feedback
        statusLabel.stringValue = "Copied to clipboard!"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.updateStatusLabel()
        }
    }
    
    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestDeleteItem item: FileShelfItem) {
        removeItem(item)
    }
    
    func fileShelfItemCell(_ cell: FileShelfItemCell, didTogglePinItem item: FileShelfItem) {
        item.isPinned.toggle()
        updateContent()
    }
} 