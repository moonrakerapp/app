import Moonraker
import Combine
import AppKit

final class Main: NSWindow {
    private var cancellables = Set<AnyCancellable>()
    private let moonraker = Moonraker()
    
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
        
        let moon = Moon()
        contentView!.addSubview(moon)
        
        moon.topAnchor.constraint(equalTo: contentView!.topAnchor).isActive = true
        moon.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor).isActive = true
        moon.leftAnchor.constraint(equalTo: contentView!.leftAnchor).isActive = true
        moon.rightAnchor.constraint(equalTo: contentView!.rightAnchor).isActive = true
        
        moonraker.illumination.receive(on: DispatchQueue.main).sink { [weak moon] in
            moon?.phase = $0.0
            moon?.fraction = $0.1
            moon?.angle = $0.2
            moon?.update()
        }.store(in: &cancellables)
        
        DispatchQueue.main.async { [weak moon] in moon?.resize() }
    }
    
    override func becomeKey() {
        super.becomeKey()
        hasShadow = true
        contentView!.subviews.forEach { $0.alphaValue = 1 }
        moonraker.update(.init())
    }
    
    override func resignKey() {
        super.resignKey()
        hasShadow = false
        contentView!.subviews.forEach { $0.alphaValue = 0.4 }
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
    
    override func zoom(_ sender: Any?) {
        contentView!.layer!.cornerRadius = isZoomed ? 10 : 0
        super.zoom(sender)
    }
}
