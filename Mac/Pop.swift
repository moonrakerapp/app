import Moonraker
import AppKit
import Combine

final class Pop: NSPopover {
    private var info: AnyCancellable!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        contentSize = .init(width: 240, height: 140)
        contentViewController = .init()
        contentViewController!.view = .init()
        behavior = .transient
        
        let phase = Label("", .medium(14), .textColor)
        contentViewController!.view.addSubview(phase)
        
        let percent = Label([])
        percent.alphaValue = 0.5
        contentViewController!.view.addSubview(percent)
        
        let date = Label("", .regular(14), .textColor)
        contentViewController!.view.addSubview(date)
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
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
        
        info = moonraker.info.receive(on: DispatchQueue.main).sink {
            phase.stringValue = .key("Phase.\($0.phase)")
            percent.attributed([("\(Int(round($0.fraction * 1000) / 10))", .bold(16), .textColor),
                                ("%", .regular(14), .textColor)])
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 1
            animation.fromValue = illumination.strokeEnd
            animation.toValue = .init($0.fraction)
            animation.timingFunction = .init(name: .easeOut)
            illumination.strokeEnd = .init($0.fraction)
            illumination.add(animation, forKey: "strokeEnd")
            
            if moonraker.offset != 0 {
                date.stringValue = formatter.string(from: moonraker.date.addingTimeInterval(moonraker.offset))
            }
        }
        
        phase.topAnchor.constraint(equalTo: contentViewController!.view.topAnchor, constant: 40).isActive = true
        phase.leftAnchor.constraint(equalTo: contentViewController!.view.leftAnchor, constant: 20).isActive = true
        
        percent.topAnchor.constraint(equalTo: phase.topAnchor).isActive = true
        percent.rightAnchor.constraint(equalTo: contentViewController!.view.rightAnchor, constant: -20).isActive = true
        
        date.topAnchor.constraint(equalTo: container.bottomAnchor, constant: 15).isActive = true
        date.centerXAnchor.constraint(equalTo: container.centerXAnchor).isActive = true
        
        container.leftAnchor.constraint(equalTo: phase.leftAnchor).isActive = true
        container.topAnchor.constraint(equalTo: phase.bottomAnchor, constant: 15).isActive = true
        container.heightAnchor.constraint(equalToConstant: 10).isActive = true
        container.widthAnchor.constraint(equalToConstant: 200).isActive = true
    }
}
