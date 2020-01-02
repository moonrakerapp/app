import Moonraker
import AppKit

final class Moon: NSView {
    var phase = Phase.new
    var fraction = Double()
    var angle = Double()
    private weak var ring: CAShapeLayer!
    private weak var face: CAShapeLayer!
    private let duration = TimeInterval(0.5)
    private let map = [Phase.new : new,
                       .waxingCrescent : waxingCrescent,
                       .firstQuarter : firstQuarter,
                       .waxingGibbous : waxingGibbous,
                       .full : full,
                       .waningGibbous : waningGibbous,
                       .lastQuarter : lastQuarter,
                       .waningCrescent : waningCrescent]
    
    private var radius: CGFloat {
        min(bounds.width, bounds.height) * 0.4
    }
    
    private var center: CGPoint {
        .init(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let ring = CAShapeLayer()
        ring.fillColor = .clear
        ring.lineWidth = 4
        ring.strokeColor = .init(gray: 1, alpha: 0.2)
        layer = ring
        wantsLayer = true
        self.ring = ring
        
        let face = CAShapeLayer()
        face.fillColor = .white
        layer!.addSublayer(face)
        self.face = face
    }
    
    override func viewDidEndLiveResize() {
        super.viewDidEndLiveResize()
        resize()
    }
    
    func resize() {
        let path = {
            $0.addArc(center: center, radius: radius, startAngle: 0, endAngle: .pi * 2, clockwise: true)
            return $0
        } (CGMutablePath()) as CGPath
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
        animation.fromValue = ring.path
        animation.toValue = path
        animation.timingFunction = .init(name: .easeOut)
        ring.path = path
        ring.add(animation, forKey: "path")
        update()
    }
    
    func update() {
        let path = map[phase]!(self)()
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = duration
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
    
    private func controls(_ start: CGPoint, _ end: CGPoint) -> (CGPoint, CGPoint) {
        let ax = start.x - center.x
        let ay = start.y - center.y
        let bx = end.x - center.x
        let by = end.y - center.y
        let q1 = (ax * ax) + (ay * ay)
        let q2 = q1 + (ax * bx) + (ay * by)
        let k2 = 4 / 3 * (sqrt(2 * q1 * q2) - q2) / ((ax * by) - (ay * bx))
        return (.init(x: center.x + ax - (k2 * ay), y: center.y + ay + (k2 * ax)),
                .init(x: center.x + bx + (k2 * by), y: center.y + by - (k2 * bx)))
    }
}
