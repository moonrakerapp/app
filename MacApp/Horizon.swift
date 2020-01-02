import AppKit

final class Horizon: NSView {
    var altitude = Double()
    var azimuth = Double()
    private let period = CGFloat(540)
    private weak var path: CAShapeLayer!
    private weak var border: CAShapeLayer!
    private weak var dash: CAShapeLayer!
    private weak var moon: CAShapeLayer!
    
    override var frame: NSRect {
        didSet {
            resize()
        }
    }
    
    private var radius: CGFloat {
        min(bounds.width, bounds.height) * 0.4
    }
    
    private var diameter: CGFloat {
        radius * 2
    }
    
    private var amplitude: CGFloat {
        radius / 2
    }
    
    private var center: CGPoint {
        .init(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let path = CAShapeLayer()
        path.fillColor = .clear
        path.lineWidth = 2
        path.strokeColor = .haze()
        path.lineCap = .round
        layer = path
        wantsLayer = true
        self.path = path
        
        let border = CAShapeLayer()
        border.fillColor = .clear
        border.lineWidth = 2
        border.strokeColor = .haze()
        path.addSublayer(border)
        self.border = border
        
        let dash = CAShapeLayer()
        dash.fillColor = .clear
        dash.lineWidth = 1
        dash.strokeColor = .haze()
        dash.lineDashPattern = [NSNumber(value: 3), NSNumber(value: 3)]
        path.addSublayer(dash)
        self.dash = dash
        
        let moon = CAShapeLayer()
        moon.fillColor = .black
        moon.strokeColor = .haze()
        moon.lineWidth = 2
        path.addSublayer(moon)
        self.moon = moon
    }
    
    func update() {
//        let path = map[phase]!(self)()
//        let animation = CABasicAnimation(keyPath: "path")
//        animation.duration = duration
//        animation.fromValue = face.path
//        animation.toValue = path
//        animation.timingFunction = .init(name: .easeOut)
//        face.path = path
//        face.add(animation, forKey: "path")
    }
    
    private func resize() {
        border.path = {
            $0.addArc(center: center, radius: radius + 1, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        
        dash.path = {
            $0.move(to: .init(x: center.x + radius, y: center.y))
            $0.addLine(to: .init(x: center.x - radius, y: center.y))
            return $0
        } (CGMutablePath())
        
        path.path = { p in
            p.move(to: .init(x: center.x - radius, y: center.y))
            stride(from: 2, through: period, by: 2).forEach {
                p.addLine(to: CGPoint(x: center.x - radius + ($0 / period * diameter),
                                      y: center.y - (sin($0 / 180 * .pi) * amplitude)))
            }
            return p
        } (CGMutablePath())
        
        moon.path = {
            $0.addArc(center: .init(x: center.x - radius + (CGFloat(altitude) / CGFloat.pi * diameter),
                                    y: center.y - (sin(.init(altitude * 3)) * amplitude)),
                      radius: radius / 5, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
    }
}
