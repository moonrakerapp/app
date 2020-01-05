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
    private let time = TimeInterval(1.5)
    private let map = [Phase.new : new,
                       .waxingCrescent : waxingCrescent,
                       .firstQuarter : firstQuarter,
                       .waxingGibbous : waxingGibbous,
                       .full : full,
                       .waningGibbous : waningGibbous,
                       .lastQuarter : lastQuarter,
                       .waningCrescent : waningCrescent]
    
    func configure() {
        fillColor = .black

        let ring = CAShapeLayer()
        ring.fillColor = .clear
        ring.lineWidth = 1
        ring.strokeColor = .haze()
        addSublayer(ring)
        self.ring = ring
        
        let face = CAShapeLayer()
        face.fillColor = .haze()
        addSublayer(face)
        self.face = face
    }
    
    func resize() {
        path = {
            $0.addArc(center: .init(), radius: radius + 1, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
        ring.path = {
            $0.addArc(center: .init(), radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    func update() {
        transform()
        animate()
    }
    
    private func transform() {
        let translate = CATransform3DTranslate(CATransform3DIdentity, center.x, center.y, 0)
        let rotate = CATransform3DRotate(translate, (.pi / 2) + .init(angle), 0, 0, 1)
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = time
        animation.fromValue = transform
        animation.toValue = rotate
        animation.timingFunction = .init(name: .easeOut)
        transform = rotate
        add(animation, forKey: "transform")
    }
    
    private func animate() {
        let path = map[phase]!(self)()
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = time
        animation.fromValue = face.path
        animation.toValue = path
        animation.timingFunction = .init(name: .easeOut)
        face.path = path
        face.add(animation, forKey: "path")
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
                        control1: .init(x: .init((fraction - 0.5) / -0.5) * (radius * 1.35), y: .init((fraction - 0.5) / -0.5) * radius),
                        control2: .init(x: .init((fraction - 0.5) / -0.5) * (radius * 1.35), y: .init((fraction - 0.5) / 0.5) * radius))
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
