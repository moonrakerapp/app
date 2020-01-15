import AppKit

final class Config: NSWindow {
    init() {
        super.init(contentRect: .init(x: 0, y: 0, width: 500, height: 500), styleMask: [.borderless, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView], backing: .buffered, defer: false)
        center()
        appearance = NSAppearance(named: .darkAqua)
        backgroundColor = .clear
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        toolbar = .init()
        toolbar!.showsBaselineSeparator = false
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.backgroundColor = .black
        contentView!.layer!.borderColor = .shade(0.5)
        contentView!.layer!.borderWidth = 1
        contentView!.layer!.cornerRadius = 5
        
    }
}
