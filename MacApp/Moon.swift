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
    private let map = [Phase.new : new,
                       .waxingCrescent : waxingCrescent,
                       .firstQuarter : firstQuarter,
                       .waxingGibbous : waxingGibbous,
                       .full : full,
                       .waningGibbous : waningGibbous,
                       .lastQuarter : lastQuarter,
                       .waningCrescent : waningCrescent]
    
    func update() {
        var tr = CATransform3DTranslate(CATransform3DIdentity, center.x, center.y, 0)
        tr = CATransform3DRotate(tr, .pi / 2, 0, 0, 1)
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 1
        animation.fromValue = transform
        animation.toValue = tr
        animation.timingFunction = .init(name: .easeOut)
        transform = tr
        add(animation, forKey: "transform")
        face.path = map[phase]!(self)()
    }
    
    func resize() {
        path = {
            $0.addArc(center: .init(), radius: radius + 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
        ring.path = {
            $0.addArc(center: .init(), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
        
    }
    
    func configure() {
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
    
    private func new() -> CGPath {
        CGMutablePath()
    }
    
    private func waxingCrescent() -> CGPath {
        {
            $0.addArc(center: .init(), radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            $0.addLine(to: .init(x: 0, y: -radius))
            $0.addCurve(to: .init(x: 0, y: radius),
                        control1: .init(x: (radius * 1.25) - (2 * radius * .init(fraction)), y: radius * -0.75),
                        control2: .init(x: (radius * 1.25) - (2 * radius * .init(fraction)), y: radius * 0.75))
            return $0
        } (CGMutablePath())
    }
    
    private func firstQuarter() -> CGPath {
        {
            $0.addArc(center: .init(), radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waxingGibbous() -> CGPath {
        {
            $0.addArc(center: .init(), radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            $0.addLine(to: .init(x: 0, y: -radius))
            $0.addCurve(to: .init(x: 0, y: radius),
                        control1: .init(x: (radius * -1.25) * .init(fraction), y: radius * -0.75),
                        control2: .init(x: (radius * -1.25) * .init(fraction), y: radius * 0.75))
            return $0
        } (CGMutablePath())
    }
    
    private func full() -> CGPath {
        {
            $0.addArc(center: .init(), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waningGibbous() -> CGPath {
        {
            $0.addArc(center: .init(), radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            $0.addLine(to: .init(x: 0, y: radius))
            $0.addCurve(to: .init(x: 0, y: -radius),
                        control1: .init(x: (radius * 1.25) * .init(fraction), y: radius * 0.75),
                        control2: .init(x: (radius * 1.25) * .init(fraction), y: radius * -0.75))
            return $0
        } (CGMutablePath())
    }
    
    private func lastQuarter() -> CGPath {
        {
            $0.addArc(center: .init(), radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    private func waningCrescent() -> CGPath {
        {
            $0.addArc(center: .init(), radius: radius, startAngle: .pi / -2, endAngle: .pi / 2, clockwise: true)
            $0.addLine(to: .init(x: 0, y: radius))
            $0.addCurve(to: .init(x: 0, y: -radius),
                        control1: .init(x: (radius * -1.25) + (2 * radius * .init(fraction)), y: radius * 0.75),
                        control2: .init(x: (radius * -1.25) + (2 * radius * .init(fraction)), y: radius * -0.75))
            return $0
        } (CGMutablePath())
    }
}
