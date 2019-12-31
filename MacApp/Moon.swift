import AppKit

final class Moon: NSView {
    private weak var face: CAShapeLayer!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let out = CAShapeLayer()
        out.fillColor = .clear
        out.lineWidth = 2
        out.strokeColor = .white
        out.path = {
            $0.addArc(center: .init(x: 50, y: 50), radius: 40, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        layer = out
        wantsLayer = true
        
        let face = CAShapeLayer()
        face.fillColor = .white
        face.path = {
            $0.move(to: .init(x: 50, y: 10))
            $0.addCurve(to: .init(x: 50, y: 90), control1: .init(x: 75, y: 50), control2: .init(x: 75, y: 50))
            return $0
        } (CGMutablePath())
        layer!.addSublayer(face)
        self.face = face
        
        widthAnchor.constraint(equalToConstant: 100).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
}
