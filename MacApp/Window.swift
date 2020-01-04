import AppKit

final class Window: NSWindow {
    private(set) weak var horizon: Horizon!
    private(set) weak var stats: Stats!
    
    override var canBecomeKey: Bool { true }
    override var acceptsFirstResponder: Bool { true }

    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 200, y: NSScreen.main!.frame.midY - 200, width: 400, height: 400), styleMask: [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView], backing: .buffered, defer: false)
        minSize = .init(width: 100, height: 100)
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
        
        let horizon = Horizon()
        contentView!.addSubview(horizon)
        self.horizon = horizon
        
        let stats = Stats()
        contentView!.addSubview(stats)
        self.stats = stats
        
        horizon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 40).isActive = true
        horizon.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 30).isActive = true
        horizon.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -30).isActive = true
        horizon.bottomAnchor.constraint(equalTo: stats.topAnchor, constant: -20).isActive = true
        
        stats.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        stats.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        stats.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
    }

    override func becomeKey() {
        super.becomeKey()
        contentView!.subviews.forEach { $0.alphaValue = 1 }
    }
    
    override func resignKey() {
        super.resignKey()
        contentView!.subviews.forEach { $0.alphaValue = 0.6 }
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
}
