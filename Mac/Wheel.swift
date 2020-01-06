import AppKit

final class Wheel: NSView {
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
        ring.lineWidth = 1
        ring.path = {
            $0.addArc(center: .init(x: 100, y: 100), radius: 93, startAngle: 0, endAngle: .pi * 2, clockwise: false)
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
        inner.fillColor = .shade()
        inner.path = {
            $0.addArc(center: .init(x: 100, y: 100), radius: 35, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer!.addSublayer(inner)
    }
}
