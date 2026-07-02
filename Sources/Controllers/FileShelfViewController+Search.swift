import Cocoa

// MARK: - Search Bar
extension FileShelfViewController: NSSearchFieldDelegate {
    var isSearchBarVisible: Bool {
        return searchBarHeightConstraint.constant > 0
    }

    func setupSearchBar() {
        searchBarContainer = NSView()
        searchBarContainer.wantsLayer = true
        searchBarContainer.layer?.backgroundColor = AppColors.headerBackground.cgColor
        searchBarContainer.layer?.masksToBounds = true
        searchBarContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchBarContainer)

        searchField = NSSearchField()
        searchField.appearance = NSAppearance(named: .darkAqua)
        searchField.placeholderString = "Search items…"
        searchField.font = DesignSystem.Typography.subtitle
        searchField.focusRingType = .none
        searchField.delegate = self
        searchField.sendsSearchStringImmediately = true
        searchField.translatesAutoresizingMaskIntoConstraints = false
        searchBarContainer.addSubview(searchField)

        searchBarHeightConstraint = searchBarContainer.heightAnchor.constraint(equalToConstant: 0)

        NSLayoutConstraint.activate([
            searchField.leadingAnchor.constraint(equalTo: searchBarContainer.leadingAnchor, constant: DesignSystem.Spacing.md),
            searchField.trailingAnchor.constraint(equalTo: searchBarContainer.trailingAnchor, constant: -DesignSystem.Spacing.md),
            searchField.centerYAnchor.constraint(equalTo: searchBarContainer.centerYAnchor),
            searchField.heightAnchor.constraint(equalToConstant: 26),
        ])
    }

    func toggleSearchBar() {
        if isSearchBarVisible {
            closeSearchBar()
        } else {
            openSearchBar()
        }
    }

    func openSearchBar() {
        guard !isSearchBarVisible else {
            view.window?.makeFirstResponder(searchField)
            return
        }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            ctx.allowsImplicitAnimation = true
            searchBarHeightConstraint.animator().constant = 36
            view.layoutSubtreeIfNeeded()
        }, completionHandler: { [weak self] in
            guard let self = self else { return }
            self.view.window?.makeFirstResponder(self.searchField)
        })
    }

    func closeSearchBar() {
        searchField.stringValue = ""
        if !searchQuery.isEmpty {
            searchQuery = ""
            updateContent()
        }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.15
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            ctx.allowsImplicitAnimation = true
            searchBarHeightConstraint.animator().constant = 0
            view.layoutSubtreeIfNeeded()
        }
        view.window?.makeFirstResponder(collectionView)
    }

    // MARK: NSSearchFieldDelegate

    func controlTextDidChange(_ notification: Notification) {
        searchQuery = searchField.stringValue
        updateContent()
    }

    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if commandSelector == #selector(cancelOperation(_:)) {
            // Esc: clear first, close on second press (or when already empty)
            if searchField.stringValue.isEmpty {
                closeSearchBar()
            } else {
                searchField.stringValue = ""
                searchQuery = ""
                updateContent()
            }
            return true
        }
        if commandSelector == #selector(NSResponder.insertNewline(_:)) {
            // Return in search: jump focus to the list so arrows/Enter work
            view.window?.makeFirstResponder(collectionView)
            return true
        }
        return false
    }
}
