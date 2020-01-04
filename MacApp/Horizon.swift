import Moonraker
import AppKit

final class Horizon: NSView {
    var info: Info! {
        didSet {
            moon.phase = info.phase
            moon.fraction = info.fraction
            moon.angle = info.angle
            azimuth = info.azimuth
            altitude = info.altitude
            update()
        }
    }
    
    private(set) weak var moon: Moon!
    private var altitude = Double.pi / 2
    private var azimuth = Double()
    private let period = CGFloat(360)
    private weak var path: CAShapeLayer!
    private weak var border: CAShapeLayer!
    private weak var dash: CAShapeLayer!
    
    override var frame: NSRect {
        didSet {
            resize()
        }
    }
    
    private var radius: CGFloat {
        min(bounds.width, bounds.height) * 0.4
    }
    
    private var bounding: CGFloat {
        (min(bounds.width, bounds.height) * 0.5) - 2
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
    
    override var mouseDownCanMoveWindow: Bool { true }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let path = CAShapeLayer()
        path.fillColor = .clear
        path.lineWidth = 1
        path.strokeColor = .shade()
        path.lineCap = .round
        layer = path
        wantsLayer = true
        self.path = path
        
        let border = CAShapeLayer()
        border.fillColor = .clear
        border.lineWidth = 1
        border.strokeColor = .shade()
        path.addSublayer(border)
        self.border = border
        
        let dash = CAShapeLayer()
        dash.fillColor = .clear
        dash.lineWidth = 1
        dash.strokeColor = .shade()
        dash.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 6)]
        path.addSublayer(dash)
        self.dash = dash
        
        let moon = Moon()
        moon.configure()
        path.addSublayer(moon)
        self.moon = moon
    }
    
    private func update() {
        moon.center = point(.init(azimuth >= 0 ? (.pi * 1.5) - altitude : altitude + (.pi / 2)) * 180 / .pi)
        moon.update()
    }
    
    private func resize() {
        border.path = {
            $0.addArc(center: center, radius: bounding, startAngle: 0, endAngle: .pi * 2, clockwise: false)
            return $0
        } (CGMutablePath())
        
        dash.path = {
            $0.move(to: .init(x: center.x + amplitude, y: center.y))
            $0.addLine(to: .init(x: center.x - amplitude, y: center.y))
            return $0
        } (CGMutablePath())
        
        path.path = { p in
            p.move(to: .init(x: center.x - radius, y: center.y - amplitude))
            stride(from: 2, through: period, by: 2).forEach {
                p.addLine(to: point($0))
            }
            return p
        } (CGMutablePath())
        
        moon.radius = radius / 4
        moon.resize()
        update()
    }
    
    private func point(_ deg: CGFloat) -> CGPoint {
        .init(x: center.x - radius + (deg / period * diameter), y: center.y - (cos(deg / 180 * .pi) * amplitude))
    }
}
