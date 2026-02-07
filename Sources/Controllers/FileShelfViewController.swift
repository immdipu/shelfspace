import Cocoa

class FileShelfViewController: NSViewController {
    // MARK: - UI Components

    var scrollView: NSScrollView!
    var collectionView: NSCollectionView!
    var headerView: HeaderView!
    var tabBar: TabBar!
    var toolbarView: ToolbarView!
    var emptyStateView: EmptyStateView!
    var dropZoneOverlay: DropZoneView!


    // Legacy compatibility
    var tabsContainer: NSView { return tabBar }
    var tabButtons: [NSButton] = []
    var tabIndicator: NSView = NSView()
    var statusLabel: NSTextField { return NSTextField() }
    var clearAllButton: NSButton { return NSButton() }
    var aboutButton: NSButton { return NSButton() }
    var quitButton: NSButton { return NSButton() }

    // MARK: - State

    var currentFilter: ContentFilter = .all
    var currentViewMode: DesignSystem.ViewMode = .list
    var items: [FileShelfItem] = []
    var filteredItems: [FileShelfItem] = []
    var maxItems: Int { SettingsStore.shared.maxItems }
    let tempDirectory: URL

    // MARK: - Initialization

    override init(nibName nibNameOrNil: NSNib.Name?, bundle nibBundleOrNil: Bundle?) {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ShelfSpace")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        self.tempDirectory = tempDir
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        let tempDir = FileManager.default.temporaryDirectory.appendingPathComponent("ShelfSpace")
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        self.tempDirectory = tempDir
        super.init(coder: coder)
    }

    // MARK: - View Lifecycle

    override func loadView() {
        view = NSView(frame: NSRect(x: 0, y: 0, width: 420, height: 600))
        setupUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.wantsLayer = true
        view.layer?.backgroundColor = AppColors.background.cgColor

        // Load persisted view mode
        currentViewMode = GridDensityManager.shared.currentViewMode
        tabBar.setViewMode(currentViewMode)

        setupCollectionView()
        loadPersistedItems()
        updateContent()

        NotificationCenter.default.addObserver(self, selector: #selector(gridDensityDidChange), name: .gridDensityChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(viewModeDidChange), name: .viewModeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearUnpinnedItems), name: .settingsDidRequestClearUnpinned, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(clearAllHistory), name: .settingsDidRequestClearAll, object: nil)
    }

    deinit { NotificationCenter.default.removeObserver(self) }

    private func loadPersistedItems() {
        let savedItems = PersistenceManager.shared.loadItems()
        if !savedItems.isEmpty {
            items = savedItems
            Logger.debug("Loaded \(savedItems.count) persisted items", category: .persistence)
        }
    }

    override func viewDidLayout() { super.viewDidLayout() }

    override func viewDidAppear() {
        super.viewDidAppear()
        if !items.isEmpty { updateContent() }
    }

    // MARK: - Setup

    private func setupUI() {
        view.wantsLayer = true
        view.layer?.backgroundColor = AppColors.background.cgColor

        setupHeader()
        setupTabBar()
        setupToolbar()
        setupEmptyState()
        setupDropZoneOverlay()
        setupCollectionView()
        setupConstraints()
    }

    private func setupHeader() {
        headerView = HeaderView()
        headerView.delegate = self
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)
    }

    private func setupTabBar() {
        tabBar = TabBar()
        tabBar.delegate = self
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)
    }

    private func setupToolbar() {
        toolbarView = ToolbarView()
        toolbarView.delegate = self
        toolbarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolbarView)
    }

    private func setupEmptyState() {
        emptyStateView = EmptyStateView()
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.isHidden = true
        view.addSubview(emptyStateView)
    }

    private func setupDropZoneOverlay() {
        dropZoneOverlay = DropZoneView()
        dropZoneOverlay.delegate = self
        dropZoneOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dropZoneOverlay)
    }

    private func setupCollectionView() {
        guard scrollView == nil, collectionView == nil else { return }

        collectionView = NSCollectionView()
        collectionView.isSelectable = true
        collectionView.allowsMultipleSelection = true
        collectionView.wantsLayer = true
        collectionView.layer?.actions = [
            "contents": NSNull(), "sublayers": NSNull(),
            "frame": NSNull(), "bounds": NSNull(), "position": NSNull()
        ]
        collectionView.registerForDraggedTypes([.fileURL, .URL, .string])
        collectionView.dataSource = self
        collectionView.delegate = self

        scrollView = NSScrollView()
        scrollView.documentView = collectionView
        scrollView.hasVerticalScroller = true
        scrollView.wantsLayer = true
        // Let the collection view background show through
        scrollView.drawsBackground = false
        scrollView.backgroundColor = AppColors.background
        scrollView.contentView.drawsBackground = false
        scrollView.contentView.backgroundColor = AppColors.background
        scrollView.contentView.wantsLayer = true
        scrollView.contentView.layer?.backgroundColor = AppColors.background.cgColor
        let themedScroller = ThemedScroller()
        themedScroller.controlSize = .mini
        themedScroller.knobStyle = .light
        scrollView.verticalScroller = themedScroller
        scrollView.scrollerStyle = .overlay
        scrollView.scrollerKnobStyle = .light
        scrollView.scrollerInsets = NSEdgeInsets(top: 4, left: 0, bottom: 4, right: 2)
        scrollView.contentInsets = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 6)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        // Match collection background to app theme
        let collectionBackgroundView = NSView()
        collectionBackgroundView.wantsLayer = true
        collectionBackgroundView.layer?.backgroundColor = AppColors.background.cgColor
        collectionView.backgroundView = collectionBackgroundView
        collectionView.backgroundColors = [AppColors.background]
        collectionView.layer?.backgroundColor = AppColors.background.cgColor
        collectionView.layer?.isOpaque = true
        view.addSubview(scrollView)

        let layout = AdaptiveGridLayout()
        collectionView.collectionViewLayout = layout
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: DesignSystem.Header.height),

            tabBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBar.heightAnchor.constraint(equalToConstant: DesignSystem.Header.tabBarHeight),

            toolbarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbarView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            scrollView.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor),

            emptyStateView.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyStateView.bottomAnchor.constraint(equalTo: toolbarView.topAnchor),

            dropZoneOverlay.topAnchor.constraint(equalTo: tabBar.bottomAnchor),
            dropZoneOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: DesignSystem.Spacing.sm),
            dropZoneOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -DesignSystem.Spacing.sm),
            dropZoneOverlay.bottomAnchor.constraint(equalTo: toolbarView.topAnchor, constant: -DesignSystem.Spacing.sm),
        ])

        view.layoutSubtreeIfNeeded()
    }

    // MARK: - View Mode & Density

    @objc private func gridDensityDidChange() {
        collectionView.collectionViewLayout?.invalidateLayout()
        collectionView.reloadData()
    }

    @objc private func viewModeDidChange() {
        collectionView.collectionViewLayout?.invalidateLayout()
        collectionView.reloadData()
    }

    // MARK: - Tab Actions

    @objc func tabButtonClicked(_ sender: NSButton) {
        let newFilter = ContentFilter.allCases[sender.tag]
        guard newFilter != currentFilter else { return }
        currentFilter = newFilter
        updateContent()
    }

    func updateTabAppearance() {}

    // MARK: - Content Management

    func updateContent() {
        guard isViewLoaded, collectionView != nil else { return }

        filteredItems = items.filter { item in
            switch currentFilter {
            case .all: return true
            case .pinned: return item.isPinned
            case .images: return item.isImage
            case .text: return item.isText
            case .files: return !item.isImage && !item.isText
            }
        }

        DispatchQueue.main.async {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.collectionView.reloadData()
            CATransaction.commit()

            self.updateStatusLabel()
            self.updateEmptyStateVisibility()
            self.updateToolbarVisibility()
            self.updateTabBadges()
        }
    }

    func updateDropZoneVisibility() {}

    func updateStatusLabel() {
        guard isViewLoaded, headerView != nil else { return }
        headerView.updateItemCount(items.count)
    }

    private func updateEmptyStateVisibility() {
        let isEmpty = filteredItems.isEmpty
        emptyStateView.isHidden = !isEmpty
        scrollView.isHidden = isEmpty
        if isEmpty {
            emptyStateView.startIdleAnimation()
        } else {
            emptyStateView.stopIdleAnimation()
        }
    }

    private func updateToolbarVisibility() {
        if items.isEmpty {
            toolbarView.hide()
        } else {
            toolbarView.show()
            toolbarView.updateItemCount(items.count)
        }
    }

    private func updateTabBadges() {
        var counts: [ContentFilter: Int] = [:]
        counts[.all] = items.count
        counts[.pinned] = items.filter { $0.isPinned }.count
        counts[.images] = items.filter { $0.isImage }.count
        counts[.text] = items.filter { $0.isText }.count
        counts[.files] = items.filter { !$0.isImage && !$0.isText }.count
        tabBar.updateItemCounts(counts)
    }

    // MARK: - Item Management

    func addItems(_ newItems: [FileShelfItem]) {
        items.insert(contentsOf: newItems, at: 0)

        if items.count > maxItems {
            let itemsToRemove = Array(items.suffix(from: maxItems))
            items.removeLast(itemsToRemove.count)
            for item in itemsToRemove {
                PersistenceManager.shared.deleteFile(for: item)
                item.cleanup()
            }
        }

        PersistenceManager.shared.saveItemsDebounced(items)
        if isViewLoaded { updateContent() }
    }

    func removeItem(_ item: FileShelfItem) {
        PersistenceManager.shared.deleteFile(for: item)
        item.cleanup()

        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items.remove(at: index)
            if let filteredIndex = filteredItems.firstIndex(where: { $0.id == item.id }) {
                filteredItems.remove(at: filteredIndex)
                collectionView.deleteItems(at: [IndexPath(item: filteredIndex, section: 0)])
            }
        }

        PersistenceManager.shared.saveItemsDebounced(items)
        updateStatusLabel()
        updateEmptyStateVisibility()
        updateToolbarVisibility()
        updateTabBadges()
    }

    @objc func clearAllItems() {
        clearUnpinnedItems()
    }

    @objc func clearUnpinnedItems() {
        let unpinnedItems = items.filter { !$0.isPinned }
        for item in unpinnedItems {
            PersistenceManager.shared.deleteFile(for: item)
            item.cleanup()
        }
        items.removeAll { !$0.isPinned }
        PersistenceManager.shared.saveItemsDebounced(items)
        updateContent()
    }

    @objc func clearAllHistory() {
        for item in items {
            PersistenceManager.shared.deleteFile(for: item)
            item.cleanup()
        }
        items.removeAll()
        PersistenceManager.shared.saveItemsDebounced(items)
        updateContent()
    }

    // MARK: - Actions

    @objc func showAbout() {
        let alert = NSAlert()
        alert.messageText = AppDelegate.appName
        alert.informativeText = """
        Version \(AppDelegate.appVersion) (Build \(AppDelegate.buildNumber))

        A lightweight temporary file and clipboard manager for macOS.

        \(AppDelegate.copyright)
        """
        alert.addButton(withTitle: "Visit GitHub")
        alert.addButton(withTitle: "OK")
        alert.alertStyle = .informational
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            if let url = URL(string: "https://github.com/immdipu") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    @objc func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Settings

    private func showSettings() {
        SettingsWindowController.shared.show()
    }


}

// MARK: - HeaderViewDelegate

extension FileShelfViewController: HeaderViewDelegate {
    func headerViewDidTapSettings(_ headerView: HeaderView) {
        showSettings()
    }

    func headerViewDidTapQuit(_ headerView: HeaderView) {
        quitApp()
    }
}

// MARK: - TabBarDelegate

extension FileShelfViewController: TabBarDelegate {
    func tabBar(_ tabBar: TabBar, didSelectFilter filter: ContentFilter) {
        currentFilter = filter
        updateContent()
    }

    func tabBar(_ tabBar: TabBar, didChangeViewMode viewMode: DesignSystem.ViewMode) {
        currentViewMode = viewMode
        GridDensityManager.shared.currentViewMode = viewMode
    }
}

// MARK: - ToolbarViewDelegate

extension FileShelfViewController: ToolbarViewDelegate {
    func toolbarViewDidTapClearAll(_ toolbarView: ToolbarView) {
        clearAllItems()
    }

    func toolbarViewDidTapSelectAll(_ toolbarView: ToolbarView) {
        let allIndexPaths = Set((0..<filteredItems.count).map { IndexPath(item: $0, section: 0) })
        collectionView.selectionIndexPaths = allIndexPaths
    }

    func toolbarViewDidTapExport(_ toolbarView: ToolbarView) {
        // TODO: Implement export
    }
}





// MARK: - DropZoneViewDelegate

extension FileShelfViewController: DropZoneViewDelegate {
    func dropZoneView(_ dropZoneView: DropZoneView, didReceiveFiles urls: [URL]) {
        handleDroppedFiles(urls)
    }
}
