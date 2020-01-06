import AppKit

final class Wheel: NSView {
    private weak var offset: Label!
    private weak var modifier: Label!
    private let formatter = DateComponentsFormatter()
    private let ratio = CGFloat(6000)
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        heightAnchor.constraint(equalToConstant: 250).isActive = true
        
        let ring = CAShapeLayer()
        ring.fillColor = .clear
        ring.strokeColor = .shade(0.3)
        ring.lineWidth = 2
        ring.path = {
            $0.addArc(center: .init(x: 100, y: 100), radius: 92.5, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(ring)
        
        let outer = CAShapeLayer()
        outer.fillColor = .clear
        outer.strokeColor = .shade(0.4)
        outer.lineWidth = 5
        outer.path = {
            $0.addArc(center: .init(x: 100, y: 100), radius: 96, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(outer)
        
        let inner = CAShapeLayer()
        inner.fillColor = .shade(0.2)
        inner.path = {
            $0.addArc(center: .init(x: 100, y: 100), radius: 32, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(inner)
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.locations = [0, 1]
        gradient.colors = [CGColor.shade(0.1), CGColor.shade(0.3)]
        gradient.cornerRadius = 30
        gradient.frame = .init(x: 70, y: 70, width: 60, height: 60)
        inner.addSublayer(gradient)
        
        let offset = Label("", .bold(14), .shade())
        addSubview(offset)
        self.offset = offset
        
        let modifier = Label("", .bold(18), .rain())
        addSubview(modifier)
        self.modifier = modifier
        
        offset.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        offset.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        modifier.centerYAnchor.constraint(equalTo: offset.centerYAnchor).isActive = true
        modifier.rightAnchor.constraint(equalTo: offset.leftAnchor).isActive = true
        
        update()
    }
    
    private func rotate(_ delta: CGFloat) {
        moonraker.offset += .init(delta * ratio)
        update()
    }
    
    private func update() {
        if moonraker.offset == 0 {
            offset.stringValue = .key("Wheel.now")
            modifier.stringValue = ""
        } else {
            offset.stringValue = formatter.string(from: abs(moonraker.offset)) ?? ""
            modifier.stringValue = moonraker.offset > 0 ? "+" : "-"
        }
    }
}
