import AppKit

final class Moon: NSView {
    var percent = Double() {
        didSet {
            let x = CGFloat(percent) * bounds.width / 2
            let animation = CABasicAnimation(keyPath: "frame.origin.x")
            animation.duration = 1
            animation.fromValue = on.frame.origin.x
            animation.toValue = x
            animation.timingFunction = .init(name: .easeOut)
            on.frame.origin.x = x
            on.add(animation, forKey: "frame.origin.x")
        }
    }
    
    private weak var on: CAShapeLayer!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let out = CAShapeLayer()
        out.fillColor = .clear
        out.lineWidth = 2
        out.strokeColor = .init(gray: 1, alpha: 0.2)
        out.path = {
            $0.addArc(center: .init(x: 50, y: 50), radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer = out
        wantsLayer = true
        
        let mask = CAShapeLayer()
        mask.fillColor = .white
        mask.path = {
            $0.addArc(center: .init(x: 50, y: 50), radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        
        let on = CAShapeLayer()
        on.fillColor = .white
        on.path = {
            $0.addArc(center: .init(x: 50, y: 50), radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        out.addSublayer(on)
        on.mask = mask
        self.on = on
        
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
