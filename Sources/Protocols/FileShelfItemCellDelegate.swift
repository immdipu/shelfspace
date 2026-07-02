import Cocoa

protocol FileShelfItemCellDelegate: AnyObject {
    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestCopyItem item: FileShelfItem)
    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestPreviewItem item: FileShelfItem)
    func fileShelfItemCell(_ cell: FileShelfItemCell, didRequestDeleteItem item: FileShelfItem)
    func fileShelfItemCell(_ cell: FileShelfItemCell, didTogglePinItem item: FileShelfItem)
}
