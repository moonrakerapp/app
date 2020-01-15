import Moonraker
import QuartzCore

final class Moon: CAShapeLayer {
    var phase = Phase.new
    var fraction = Double()
    var angle = Double()
    var middle = CGPoint()
    var radius = CGFloat()
    private weak var face: CAShapeLayer!
    private weak var surface: CAShapeLayer!
    private let map = [Phase.new : new,
                       .waxingCrescent : waxingCrescent,
                       .firstQuarter : firstQuarter,
                       .waxingGibbous : waxingGibbous,
                       .full : full,
                       .waningGibbous : waningGibbous,
                       .lastQuarter : lastQuarter,
                       .waningCrescent : waningCrescent]
    
    private var refresh: CGPath {
        {
            $0.addArc(center: .init(), radius: radius + 1, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath())
    }
    
    required init?(coder: NSCoder) { nil }
    override init(layer: Any) {
        super.init(layer: layer)
    }
    
    override init() {
        super.init()
        fillColor = .black
        strokeColor = .shade()
        shadowColor = .haze()
        shadowOpacity = 1
        lineWidth = 2
        shadowOffset = .zero
        
        let face = CAShapeLayer()
        face.fillColor = .haze()
        addSublayer(face)
        self.face = face
        
        let surface = CAShapeLayer()
        surface.fillColor = .init(srgbRed: 0, green: 0, blue: 0, alpha: 0.1)
        addSublayer(surface)
        self.surface = surface
    }
    
    func resize() {
        path = refresh
        shadowRadius = radius
        surface.path = craters()
    }
    
    func animate() {
        animate(self, refresh)
        animate(face, map[phase]!(self)())
        animate(surface, craters())
        animateRadius()
        animateMiddle()
    }
    
    func update() {
        face.path = map[phase]!(self)()
        animateMiddle()
    }
    
    private func animate(_ layer: CAShapeLayer, _ path: CGPath) {
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = 1
        animation.fromValue = layer.path
        animation.toValue = path
        animation.timingFunction = .init(name: .easeOut)
        layer.path = path
        layer.add(animation, forKey: "path")
    }
    
    private func animateRadius() {
        let animation = CABasicAnimation(keyPath: "shadowRadius")
        animation.duration = 2
        animation.fromValue = shadowRadius
        animation.toValue = radius
        animation.timingFunction = .init(name: .easeOut)
        shadowRadius = radius
        add(animation, forKey: "shadowRadius")
    }
    
    private func animateMiddle() {
        let rotate = rotation(CATransform3DTranslate(CATransform3DIdentity, middle.x, middle.y, 0))
        let animation = CABasicAnimation(keyPath: "transform")
        animation.duration = 1.5
        animation.fromValue = transform
        animation.toValue = rotate
        animation.timingFunction = .init(name: .easeOut)
        transform = rotate
        add(animation, forKey: "transform")
    }
    
    #if os(macOS)
    private func rotation(_ translate: CATransform3D) -> CATransform3D {
        CATransform3DRotate(translate, (.pi / 2) - .init(angle), 0, 0, 1)
    }
    #endif
    #if os(iOS)
    private func rotation(_ translate: CATransform3D) -> CATransform3D {
        CATransform3DRotate(translate, (.pi / -2) + .init(angle), 0, 0, 1)
    }
    #endif
    
    private func new() -> CGPath {
        CGMutablePath()
    }
    
    private func waxingCrescent() -> CGPath {
        {
            $0.addArc(center: .init(), radius: radius, startAngle: .pi / 2, endAngle: .pi / -2, clockwise: true)
            $0.addLine(to: .init(x: 0, y: -radius))
            $0.addCurve(to: .init(x: 0, y: radius),
                        control1: .init(x: .init((fraction - 0.5) / -0.5) * (radius * 1.35), y: .init((fraction - 0.5) / 0.5) * radius),
                        control2: .init(x: .init((fraction - 0.5) / -0.5) * (radius * 1.35), y: .init((fraction - 0.5) / -0.5) * radius))
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
                        control1: .init(x: .init((fraction - 0.5) / 0.5) * (radius * 1.35), y: .init((fraction - 0.5) / 0.5) * radius),
                        control2: .init(x: .init((fraction - 0.5) / 0.5) * (radius * 1.35), y: .init((fraction - 0.5) / -0.5) * radius))
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
                        control1: .init(x: .init((fraction - 0.5) / 0.5) * (radius * 1.35), y: .init((fraction - 0.5) / -0.5) * radius),
                        control2: .init(x: .init((fraction - 0.5) / 0.5) * (radius * 1.35), y: .init((fraction - 0.5) / 0.5) * radius))
            return $0
        } (CGMutablePath())
    }
    
    private func craters() -> CGPath {
        let path = CGMutablePath()
        path.addPath({
            $0.addArc(center: .init(x: radius / -3, y: radius / -3.5), radius: radius / 2.2, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: .init(x: radius / -3, y: radius / 2.25), radius: radius / 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: .init(x: radius / 2, y: radius / 3.5), radius: radius / 4, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: .init(x: radius / 6, y: radius / 1.5), radius: radius / 5, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath()))
        path.addPath({
            $0.addArc(center: .init(x: radius / 4, y: radius / -1.5), radius: radius / 6, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath()))
        return path
    }
}
