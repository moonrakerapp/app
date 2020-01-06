import Moonraker
import AppKit

final class Pop: NSPopover {
    var info: Info! {
        didSet {
            phase.stringValue = .key("Phase.\(info.phase)")
            percent.attributed([("\(Float(Int(info.fraction * 100000)) / 1000)", .bold(16), .textColor),
                                ("%", .regular(14), .textColor)])
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 2
            animation.fromValue = illumination.strokeEnd
            animation.toValue = .init(info.fraction)
            animation.timingFunction = .init(name: .easeOut)
            illumination.strokeEnd = .init(info.fraction)
            illumination.add(animation, forKey: "strokeEnd")
        }
    }
    
    private weak var phase: Label!
    private weak var percent: Label!
    private weak var illumination: CAShapeLayer!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        contentSize = .init(width: 240, height: 300)
        contentViewController = .init()
        contentViewController!.view = .init()
        behavior = .transient
        
        let phase = Label("", .bold(20), .textColor)
        contentViewController!.view.addSubview(phase)
        self.phase = phase
        
        let _illumination = Label(.key("Pop.illumination"), .regular(16), .textColor)
        contentViewController!.view.addSubview(_illumination)
        
        let percent = Label([])
        percent.alphaValue = 0.4
        contentViewController!.view.addSubview(percent)
        self.percent = percent
        
        let container = NSView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.wantsLayer = true
        container.layer!.cornerRadius = 5
        container.layer!.borderWidth = 1
        container.layer!.borderColor = NSColor.textColor.cgColor
        contentViewController!.view.addSubview(container)
        
        let illumination = CAShapeLayer()
        illumination.fillColor = .clear
        illumination.strokeColor = NSColor.textColor.cgColor
        illumination.lineWidth = 10
        illumination.path = {
            $0.move(to: .init(x: 0, y: 5))
            $0.addLine(to: .init(x: 200, y: 5))
            return $0
        } (CGMutablePath())
        illumination.strokeEnd = 0
        container.layer!.addSublayer(illumination)
        self.illumination = illumination
        
        let base = NSView()
        base.translatesAutoresizingMaskIntoConstraints = false
        base.wantsLayer = true
        contentViewController!.view.addSubview(base)
        
        let moon = Moon()
//        moon.radius = 5
        moon.center = .init(x: 50, y: 50)
        moon.resize()
        moon.update()
        base.layer!.addSublayer(moon)
        
        base.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 20).isActive = true
        base.leftAnchor.constraint(equalTo: contentViewController!.view.leftAnchor, constant: 20).isActive = true
        base.widthAnchor.constraint(equalToConstant: 200).isActive = true
        base.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        phase.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 100).isActive = true
        phase.leftAnchor.constraint(equalTo: contentViewController!.view.leftAnchor, constant: 20).isActive = true
        
        _illumination.topAnchor.constraint(equalTo: phase.bottomAnchor, constant: 20).isActive = true
        _illumination.leftAnchor.constraint(equalTo: phase.leftAnchor).isActive = true
        
        percent.topAnchor.constraint(equalTo: _illumination.topAnchor).isActive = true
        percent.rightAnchor.constraint(equalTo: contentViewController!.view.rightAnchor, constant: -20).isActive = true
        
        container.leftAnchor.constraint(equalTo: phase.leftAnchor).isActive = true
        container.topAnchor.constraint(equalTo: _illumination.bottomAnchor, constant: 6).isActive = true
        container.heightAnchor.constraint(equalToConstant: 10).isActive = true
        container.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
    
    @objc private func update() {
//        let animation = CABasicAnimation(keyPath: "strokeEnd")
//        animation.duration = 0.3
//        animation.fromValue = illumination.strokeEnd
//        animation.toValue = 0
//        illumination.strokeEnd = 0
//        illumination.add(animation, forKey: "strokeEnd")
//        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            (NSApp as! App).update()
//        }
    }
}
