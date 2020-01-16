import Moonraker
import AppKit
import Combine

final class Horizon: NSView {
    var zoom = false {
        didSet {
            animate(dash)
            animate(path)
            moon.radius = moonradius
            moon.middle = moonmiddle
            moon.animate()
        }
    }
    
    private var altitude = Double.pi / 2
    private var azimuth = Double()
    private var sub: AnyCancellable!
    private let period = CGFloat(360)
    private weak var moon: Moon!
    private weak var path: CAShapeLayer!
    private weak var dash: CAShapeLayer!
    
    override var frame: NSRect {
        didSet {
            resize()
        }
    }
    
    private var radius: CGFloat {
        (min(bounds.width, bounds.height) * 0.5) - 2
    }
    
    private var amplitude: CGFloat {
        radius / 3
    }
    
    private var moonradius: CGFloat {
        zoom ? radius / 3 : radius / 8
    }
    
    private var moonmiddle: CGPoint {
        zoom ? middle : point(.init(azimuth >= 0 ? (.pi * 1.5) - altitude : altitude + (.pi / 2)) * 180 / .pi)
    }
    
    private var middle: CGPoint {
        .init(x: bounds.width / 2, y: bounds.height / 2)
    }
    
    override var mouseDownCanMoveWindow: Bool { true }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let path = CAShapeLayer()
        path.fillColor = .clear
        path.strokeColor = .shade()
        path.lineCap = .round
        path.strokeEnd = 1
        layer = path
        wantsLayer = true
        self.path = path
        
        let dash = CAShapeLayer()
        dash.lineWidth = 1
        dash.fillColor = .clear
        dash.strokeColor = .shade()
        dash.lineCap = .round
        dash.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 5)]
        dash.strokeEnd = 1
        path.addSublayer(dash)
        self.dash = dash
        
        let moon = Moon()
        path.addSublayer(moon)
        self.moon = moon
        
        sub = moonraker.travel.receive(on: DispatchQueue.main).sink {
            self.azimuth = $0.azimuth
            self.altitude = $0.altitude
            moon.phase = $0.phase
            moon.fraction = $0.fraction
            moon.angle = $0.angle
            moon.middle = self.moonmiddle
            moon.update()
        }
    }
    
    private func resize() {
        dash.path = {
            $0.move(to: .init(x: middle.x + amplitude, y: middle.y))
            $0.addLine(to: .init(x: middle.x - amplitude, y: middle.y))
            return $0
        } (CGMutablePath())
        
        path.path = { p in
            p.move(to: .init(x: middle.x - radius, y: middle.y - amplitude))
            stride(from: 2, through: period, by: 2).forEach {
                p.addLine(to: point($0))
            }
            return p
        } (CGMutablePath())
        
        path.lineWidth = radius < 50 ? 1 : radius < 100 ? 2 : radius < 200 ? 3 : 4
        moon.radius = moonradius
        moon.middle = moonmiddle
        moon.resize()
        moon.update()
    }
    
    private func point(_ deg: CGFloat) -> CGPoint {
        .init(x: middle.x - radius + (deg / period * (radius * 2)), y: middle.y - (cos(deg / 180 * .pi) * amplitude))
    }
    
    private func animate(_ layer: CAShapeLayer) {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = 1
        animation.fromValue = layer.strokeEnd
        animation.toValue = zoom ? 0 : 1
        animation.timingFunction = .init(name: .easeOut)
        layer.strokeEnd = zoom ? 0 : 1
        layer.add(animation, forKey: "strokeEnd")
    }
}
