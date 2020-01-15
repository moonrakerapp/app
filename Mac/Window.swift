import AppKit

final class Window: NSWindow {
    init() {
        super.init(contentRect: .init(x: NSScreen.main!.frame.midX - 300, y: NSScreen.main!.frame.midY - 400, width: 600, height: 800), styleMask: [.borderless, .miniaturizable, .resizable, .closable, .titled, .unifiedTitleAndToolbar, .fullSizeContentView], backing: .buffered, defer: false)
        minSize = .init(width: 200, height: 250)
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
        contentView!.layer!.borderWidth = 1
        contentView!.layer!.borderColor = .shade(0.5)
        contentView!.layer!.cornerRadius = 5
        
        let graph = Graph()
        contentView!.addSubview(graph)
        
        let equalizer = NSView()
        equalizer.translatesAutoresizingMaskIntoConstraints = false
        equalizer.wantsLayer = true
        equalizer.layer!.addSublayer(Equalizer())
        contentView!.addSubview(equalizer)
        
        let horizon = Horizon()
        contentView!.addSubview(horizon)
        
        let wheel = Wheel()
        wheel.horizon = horizon
        contentView!.addSubview(wheel)
        
        horizon.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        horizon.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 20).isActive = true
        horizon.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -20).isActive = true
        horizon.bottomAnchor.constraint(equalTo: graph.topAnchor, constant: 60).isActive = true
        
        equalizer.widthAnchor.constraint(equalToConstant: 160).isActive = true
        equalizer.heightAnchor.constraint(equalToConstant: 80).isActive = true
        equalizer.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        equalizer.bottomAnchor.constraint(equalTo: wheel.topAnchor, constant: 20).isActive = true
        
        graph.topAnchor.constraint(greaterThanOrEqualTo: contentView!.topAnchor, constant: 140).isActive = true
        graph.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        graph.bottomAnchor.constraint(equalTo: equalizer.topAnchor).isActive = true
        
        wheel.centerXAnchor.constraint(equalTo: contentView!.centerXAnchor).isActive = true
        let bottom = wheel.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -40)
        bottom.priority = .defaultLow
        bottom.isActive = true
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
