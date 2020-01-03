import Moonraker
import AppKit

final class Moon: CAShapeLayer {
    var phase = Phase.new
    var fraction = Double()
    var angle = Double()
    var center = CGPoint()
    var radius = CGFloat()
    private weak var face: CAShapeLayer!
    private weak var ring: CAShapeLayer!
    private let time = TimeInterval(1)
    private let map = [Phase.new : new,
                       .waxingCrescent : waxingCrescent,
                       .firstQuarter : firstQuarter,
                       .waxingGibbous : waxingGibbous,
                       .full : full,
                       .waningGibbous : waningGibbous,
                       .lastQuarter : lastQuarter,
                       .waningCrescent : waningCrescent]
    
    private var location: CGPath {
        {
            $0.addArc(center: center, radius: radius + 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private var border: CGPath {
        {
            $0.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        fillColor = .black

        let ring = CAShapeLayer()
        ring.fillColor = .clear
        ring.lineWidth = 2
        ring.strokeColor = .haze()
        addSublayer(ring)
        self.ring = ring
        
        let face = CAShapeLayer()
        face.fillColor = .haze()
        addSublayer(face)
        self.face = face
    }
    
    func update() {
        updateFace()
        updateRing()
        updateLocation()
    }
    
    func resize() {
        path = location
        ring.path = border
        face.path = map[phase]!(self)()
    }
    
    private func updateFace() {
        let path = map[phase]!(self)()
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = time
        animation.fromValue = face.path
        animation.toValue = path
        animation.timingFunction = .init(name: .easeOut)
        face.path = path
        face.add(animation, forKey: "path")
    }
    
    private func updateRing() {
        let path = border
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = time
        animation.fromValue = ring.path
        animation.toValue = path
        animation.timingFunction = .init(name: .easeOut)
        ring.path = path
        ring.add(animation, forKey: "path")
    }
    
    private func updateLocation() {
        let location = self.location
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = time
        animation.fromValue = path
        animation.toValue = location
        animation.timingFunction = .init(name: .easeOut)
        path = location
        add(animation, forKey: "path")
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
