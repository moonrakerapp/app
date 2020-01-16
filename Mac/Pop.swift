import Moonraker
import AppKit
import Combine

final class Pop: NSPopover {
    private var info: AnyCancellable!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        contentSize = .init(width: 300, height: 280)
        contentViewController = .init()
        contentViewController!.view = .init()
        behavior = .transient
        
        let phase = Label("", .regular(16), .textColor)
        contentViewController!.view.addSubview(phase)
        
        let percent = Label([])
        contentViewController!.view.addSubview(percent)
        
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.wantsLayer = true
        contentViewController!.view.addSubview(container)
        
        let moon = Moon()
        moon.radius = 30
        moon.middle = .init(x: 150, y: 120)
        moon.resize()
        moon.update()
        container.layer!.addSublayer(moon)
        
        info = moonraker.now.receive(on: DispatchQueue.main).sink {
            phase.stringValue = .key("Phase.\($0.phase)")
            percent.attributed([("\(Int(round($0.fraction * 1000) / 10))", .bold(20), .textColor),
                                ("%", .regular(14), .textColor)])
            moon.phase = $0.phase
            moon.fraction = $0.fraction
            moon.angle = $0.angle
            moon.update()
        }
        
        percent.topAnchor.constraint(equalTo: container.bottomAnchor, constant: -30).isActive = true
        percent.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
        
        phase.topAnchor.constraint(equalTo: percent.bottomAnchor, constant: 2).isActive = true
        phase.centerXAnchor.constraint(equalTo: contentViewController!.view.centerXAnchor).isActive = true
        
        container.leftAnchor.constraint(equalTo: contentViewController!.view.leftAnchor).isActive = true
        container.rightAnchor.constraint(equalTo: contentViewController!.view.rightAnchor).isActive = true
        container.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: -30).isActive = true
        container.heightAnchor.constraint(equalToConstant: 240).isActive = true
    }
}
