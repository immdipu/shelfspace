# ShelfSpace UX Improvements — Design

**Date:** 2026-07-02
**Status:** Awaiting user review

## Goal

Make ShelfSpace feel smoother and faster: fix the close button (it currently quits the app), add a fast in-popover preview for image and text items, and add three polish features (search, keyboard navigation, copy feedback).

## Decisions already made with the user

- Preview appears as an **in-popover overlay** covering the 420×600 popover (not Quick Look, not a separate window).
- Preview is triggered by a **hover eye button** on cells and by **Space** with an item selected.

## 1. Close button fix

**Bug:** `HeaderView`'s ✕ button fires `headerViewDidTapQuit`, which `FileShelfViewController` handles with `NSApplication.shared.terminate(nil)` (FileShelfViewController.swift:408–410).

**Fix:**
- Rename the delegate method to `headerViewDidTapClose(_:)`.
- Handler closes the popover: `(NSApp.delegate as? AppDelegate)?.closePopover(nil)`.

**Required companion change — quit affordance.** The ✕ button is currently the only way to quit. Add a right-click (or ctrl-click) context menu on the status bar item:

- Open ShelfSpace (toggles popover)
- Settings…
- Quit ShelfSpace (⌘Q)

Left-click keeps toggling the popover exactly as today. Implementation: in `AppDelegate.setupMenuBar()`, send action on both `.leftMouseUp` and `.rightMouseUp` (`button.sendAction(on:)`), branch on `NSApp.currentEvent?.type`; show an `NSMenu` via `statusBarItem.menu` assignment + `button.performClick` pattern (assign menu, pop it, then nil it so left-click behavior is preserved).

## 2. Preview overlay

New view: `Sources/Views/PreviewOverlayView.swift`.

### Layout (matches V0 dark aesthetic, tokens from DesignSystem/AppColors)

- Fills the popover's root view, background `AppColors.background` (opaque — fully covers list).
- Header row (44px): `←` back HeaderButton, item display name (truncating middle), item-type badge.
- Content area: flexible.
- Footer row (52px): Copy / Pin / Delete `ActionButton`s operating on the previewed item; delete dismisses the overlay.

### Content behavior

- **Images:** `NSImageView` with `.scaleProportionallyDown`. Show the already-cached cell thumbnail immediately (zero-wait paint), then decode the full-resolution image from `item.fileURL` on a utility queue and swap it in on main. Never decode on the main thread.
- **Text:** read-only, selectable `NSTextView` inside `NSScrollView`; monospaced font when the existing `isTextFile`/code heuristics say it looks like code; normal body font otherwise. Content from `item.textContent` or file contents (read async, cap display at ~1MB with a "truncated" notice).
- **Eligibility:** `item.isImage || item.isText` (plus text-readable files). Other types never show the eye button.

### Transitions & dismissal

- Present: fade + slight scale (0.96→1.0), 0.18s, `NSAnimationContext.runAnimationGroup`.
- Dismiss: Esc, `←` back button, or the footer Delete action. Reverse animation, then remove from superview.
- Overlay owns first responder while shown so Esc/Space don't leak to the list.

### Trigger plumbing

- `FileShelfItemCellDelegate` gains `fileShelfItemCell(_:didRequestPreviewItem:)`.
- Eye button (`eye` SF Symbol) added leftmost in the hover action cluster of `FileShelfItemCell` for both grid (32×32) and list (28×28) modes, hidden for ineligible types.
- `FileShelfViewController` implements the delegate method and Space-key handling; both call `showPreview(for:)`.

## 3. Search bar

- Magnifier `HeaderButton` in `HeaderView` (left of settings) and `⌘F` both reveal a search row (36px, `NSSearchField`, themed) between header and tab bar; it animates in and grabs focus.
- Live filtering: `searchQuery` on `FileShelfViewController`; `filteredItems` = tab filter ∧ (filename contains query ∨ textContent contains query), case-insensitive. Recomputed on every text change (item counts are small; no debounce needed).
- Esc with empty field (or the field's cancel button) closes the row and restores the unfiltered list. Tab counts continue to reflect tab filters, not search.

## 4. Keyboard navigation

Handled via `keyDown` override on the popover root view (custom `NSView` subclass) with the collection view's selection as state:

- **Arrows:** NSCollectionView native selection movement (ensure `collectionView` can be first responder; forward arrows to it).
- **Enter/Return:** copy selected item (same path as copy button).
- **Space:** preview selected item (if eligible).
- **Esc:** priority chain — close preview if shown, else close search if shown, else close popover.
- **⌘F:** open search.

## 5. Copy feedback polish

On any copy action: the copy button's icon morphs to `checkmark` with accent tint for 1s, then reverts (CALayer swap wrapped in `CATransaction.setDisableActions(true)` + brief fade); the card layer runs a subtle accent-border pulse (borderColor/borderWidth animation, ~0.4s). No layout changes, no reload.

## Error handling

- Full-res image fails to load → keep showing thumbnail; no error UI.
- Text file unreadable → show "Couldn't load content" placeholder in the overlay.
- Preview requested for a deleted/missing file → fall back to whatever is cached; Copy still works from cache when possible.

## Testing

No test suite exists; verification is manual via `make watch`:

1. ✕ closes popover only; app stays in menu bar; right-click menu quits.
2. Eye button/Space opens preview instantly for a large image (no beachball); Esc dismisses.
3. Text/code preview scrolls, selects, shows monospace for code.
4. ⌘F search narrows list live; Esc unwinds preview → search → popover.
5. Arrows/Enter/Space work without mouse; copy shows checkmark + pulse.

## Out of scope (future ideas)

Global hotkey (⌘⇧V), drag-out visual feedback, paste-as-plain-text, bulk actions on multi-selection, video/archive previews.
