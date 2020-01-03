import Moonraker
import Combine
import AppKit

final class Main: NSWindow {
    private var cancellables = Set<AnyCancellable>()
    private let moonraker = Moonraker()
    
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
        
        horizon.topAnchor.constraint(equalTo: contentView!.topAnchor, constant: 30).isActive = true
        horizon.bottomAnchor.constraint(equalTo: contentView!.bottomAnchor, constant: -30).isActive = true
        horizon.leftAnchor.constraint(equalTo: contentView!.leftAnchor, constant: 30).isActive = true
        horizon.rightAnchor.constraint(equalTo: contentView!.rightAnchor, constant: -30).isActive = true
        
        moonraker.illumination.receive(on: DispatchQueue.main).sink { [weak horizon] in
            horizon?.moon.phase = $0.0
            horizon?.moon.fraction = $0.1
            horizon?.moon.angle = $0.2
            horizon?.moon.update()
        }.store(in: &cancellables)
        
        moonraker.position.receive(on: DispatchQueue.main).sink { [weak horizon] in
            horizon?.azimuth = $0.0
            horizon?.altitude = $0.1
            horizon?.update()
        }.store(in: &cancellables)
    }
    
    override func becomeKey() {
        super.becomeKey()
        contentView!.subviews.forEach { $0.alphaValue = 1 }
//        moonraker.update(.init(), latitude: -41.136516, longitude: -66.093667)
        moonraker.update(.init(), latitude: 0, longitude: 0)
    }
    
    override func resignKey() {
        super.resignKey()
        contentView!.subviews.forEach { $0.alphaValue = 0.6 }
    }
    
    override func close() {
        NSApp.terminate(nil)
    }
}
