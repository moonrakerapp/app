import AppKit

final class Main: NSWindow {
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 300, y: NSScreen.main!.frame.midY - 200, width: 600, height: 400), styleMask: [.borderless, .miniaturizable, .resizable], backing: .buffered, defer: false)
        minSize = .init(width: 100, height: 100)
        appearance = NSAppearance(named: .darkAqua)
        backgroundColor = .clear
        isOpaque = false
        collectionBehavior = .fullScreenNone
        isReleasedWhenClosed = false
        isMovableByWindowBackground = true
        contentView!.wantsLayer = true
        contentView!.layer!.cornerRadius = 10
        contentView!.layer!.backgroundColor = .black
    }
    
    override func becomeKey() {
        super.becomeKey()
        hasShadow = true
        contentView!.subviews.forEach { $0.alphaValue = 1 }
    }
    
    override func resignKey() {
        super.resignKey()
        hasShadow = false
        contentView!.subviews.forEach { $0.alphaValue = 0.4 }
    }
    
    override func close() { app.terminate(nil) }
    
    override func zoom(_ sender: Any?) {
        contentView!.layer!.cornerRadius = isZoomed ? 10 : 0
        super.zoom(sender)
    }
}
