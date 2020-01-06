import AppKit

final class Window: NSWindow {
    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 400, y: NSScreen.main!.frame.midY - 400, width: 800, height: 800), styleMask: [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView], backing: .buffered, defer: false)
        minSize = .init(width: 150, height: 150)
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
        
        let stats = Stats()
        contentView!.addSubview(stats)
        
        let graph = Graph()
        contentView!.addSubview(graph)
        
        let wheel = Wheel()
        contentView!.addSubview(wheel)
        
        horizon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 30).isActive = true
        horizon.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 40).isActive = true
        horizon.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -40).isActive = true
        horizon.bottomAnchor.constraint(equalTo: wheel.topAnchor, constant: -40).isActive = true
        
        wheel.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        wheel.bottomAnchor.constraint(equalTo: stats.topAnchor, constant: -40).isActive = true
        wheel.topAnchor.constraint(greaterThanOrEqualTo: contentView!.topAnchor, constant: 200).isActive = true
        
        stats.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        stats.rightAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        let bottom = stats.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor)
        bottom.priority = .defaultLow
        bottom.isActive = true
        
        graph.leftAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        graph.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        graph.topAnchor.constraint(equalTo: stats.topAnchor).isActive = true
        graph.bottomAnchor.constraint(equalTo: stats.bottomAnchor).isActive = true
    }

    override func becomeKey() {
        super.becomeKey()
        contentView!.subviews.forEach { $0.alphaValue = 1 }
    }
    
    override func resignKey() {
        super.resignKey()
        contentView!.subviews.forEach { $0.alphaValue = 0.5 }
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
}
