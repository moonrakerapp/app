import Moonraker
import AppKit

final class Moon: NSView {
    var phase = Phase.new
    var fraction = Double()
    var angle = Double()
    private weak var ring: CAShapeLayer!
    private weak var face: CAShapeLayer!
    private let map = [Phase.new : new,
                       .waxingCrescent : waxingCrescent,
                       .firstQuarter : firstQuarter,
                       .waxingGibbous : waxingGibbous,
                       .full : full,
                       .waningGibbous : waningGibbous,
                       .lastQuarter : lastQuarter,
                       .waningCrescent : waningCrescent]
    
    override var frame: NSRect {
        didSet {
            resize()
        }
    }
    
    private var radius: CGFloat {
        min(bounds.width, bounds.height) * 0.4
    }
    
    private var center: CGPoint {
        .init(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let ring = CAShapeLayer()
        ring.fillColor = .clear
        ring.lineWidth = 5
        ring.strokeColor = .haze()
        layer = ring
        wantsLayer = true
        self.ring = ring
        
        let face = CAShapeLayer()
        face.fillColor = .haze()
        ring.addSublayer(face)
        self.face = face
    }
    
    func update() {
        let path = map[phase]!(self)()
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 0.5
        animation.fromValue = face.path
        animation.toValue = path
        animation.timingFunction = .init(name: .easeOut)
        face.path = path
        face.add(animation, forKey: "path")
    }
    
    private func resize() {
        ring.path = {
            $0.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
        face.path = map[phase]!(self)()
    }
    
    private func new() -> CGPath {
        CGMutablePath()
    }
    
    private func waxingCrescent() -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            $0.addLine(to: .init(x: center.x, y: center.y - radius))
            $0.addCurve(to: .init(x: center.x, y: center.y + radius),
                        control1: .init(x: center.x + (radius * 1.25) - (2 * radius * .init(fraction)), y: center.y - (radius * 0.75)),
                        control2: .init(x: center.x + (radius * 1.25) - (2 * radius * .init(fraction)), y: center.y + (radius * 0.75)))
            return $0
        } (CGMutablePath())
    }
    
    private func firstQuarter() -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waxingGibbous() -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            $0.addLine(to: .init(x: center.x, y: center.y - radius))
            $0.addCurve(to: .init(x: center.x, y: center.y + radius),
                        control1: .init(x: center.x - ((radius * 1.25) * .init(fraction)), y: center.y - (radius * 0.75)),
                        control2: .init(x: center.x - ((radius * 1.25) * .init(fraction)), y: center.y + (radius * 0.75)))
            return $0
        } (CGMutablePath())
    }
    
    private func full() -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waningGibbous() -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            $0.addLine(to: .init(x: center.x, y: center.y + radius))
            $0.addCurve(to: .init(x: center.x, y: center.y - radius),
                        control1: .init(x: center.x + ((radius * 1.25) * .init(fraction)), y: center.y + (radius * 0.75)),
                        control2: .init(x: center.x + ((radius * 1.25) * .init(fraction)), y: center.y - (radius * 0.75)))
            return $0
        } (CGMutablePath())
    }
    
    private func lastQuarter() -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waningCrescent() -> CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            $0.addLine(to: .init(x: center.x, y: center.y + radius))
            $0.addCurve(to: .init(x: center.x, y: center.y - radius),
                        control1: .init(x: center.x - (radius * 1.25) + (2 * radius * .init(fraction)), y: center.y + (radius * 0.75)),
                        control2: .init(x: center.x - (radius * 1.25) + (2 * radius * .init(fraction)), y: center.y - (radius * 0.75)))
            return $0
        } (CGMutablePath())
    }
}
