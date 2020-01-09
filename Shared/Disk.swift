import QuartzCore

final class Disk: CAShapeLayer {
    private weak var ring: CAShapeLayer!
    private weak var inner: CAShapeLayer!
    private weak var gradient: CAGradientLayer!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        fillColor = .clear
        strokeColor = .shade(0.3)
        lineWidth = 3
        path = {
            $0.addArc(center: .init(x: 150, y: 170), radius: 116, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        
        let ring = CAShapeLayer()
        ring.lineWidth = 1
        ring.path = {
            $0.addArc(center: .init(x: 150, y: 170), radius: 112.5, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        addSublayer(ring)
        self.ring = ring
        
        let inner = CAShapeLayer()
        inner.fillColor = .black
        inner.lineWidth = 1
        inner.path = {
            $0.addArc(center: .init(x: 150, y: 170), radius: 45, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        addSublayer(inner)
        self.inner = inner
        
        let gradient = CAGradientLayer()
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        gradient.locations = [0, 1]
        gradient.colors = [CGColor(srgbRed: 0, green: 0, blue: 0, alpha: 0.5), CGColor.clear]
        gradient.cornerRadius = 120
        gradient.frame = .init(x: 31, y: 51, width: 238, height: 238)
        addSublayer(gradient)
        self.gradient = gradient
    }
    
    func rotate(_ radians: CGFloat) {
        gradient.transform = CATransform3DRotate(CATransform3DIdentity, radians, 0, 0, 1)
    }
    
    func animate(_ drag: Drag) {
        switch drag {
        case .no:
            inner.strokeColor = .haze(0.2)
            ring.strokeColor = .haze(0.2)
            ring.fillColor = .shade()
        default:
            inner.strokeColor = .haze(0.6)
            ring.strokeColor = .haze(0.6)
            ring.fillColor = .shade(0.6)
        }
    }
}
