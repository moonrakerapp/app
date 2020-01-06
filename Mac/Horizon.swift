import Moonraker
import AppKit
import Combine

final class Horizon: NSView {
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
    
    private var diameter: CGFloat {
        radius * 2
    }
    
    private var amplitude: CGFloat {
        radius / 3
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
        path.strokeColor = .shade()
        path.lineCap = .round
        path.masksToBounds = false
        layer = path
        wantsLayer = true
        self.path = path
        
        let dash = CAShapeLayer()
        dash.fillColor = .clear
        dash.lineWidth = 1
        dash.strokeColor = .shade()
        dash.lineCap = .round
        dash.lineDashPattern = [NSNumber(value: 1), NSNumber(value: 5)]
        path.addSublayer(dash)
        self.dash = dash
        
        let moon = Moon()
        path.addSublayer(moon)
        self.moon = moon
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            moon.phase = $0.phase
            moon.fraction = $0.fraction
            moon.angle = $0.angle
            self.azimuth = $0.azimuth
            self.altitude = $0.altitude
            self.update()
        }
    }
    
    private func resize() {
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
        
        path.lineWidth = radius < 50 ? 1 : radius < 100 ? 2 : radius < 200 ? 3 : 4
        moon.radius = radius / 8
        moon.resize()
        update()
    }
    
    private func update() {
        moon.center = point(.init(azimuth >= 0 ? (.pi * 1.5) - altitude : altitude + (.pi / 2)) * 180 / .pi)
        moon.update()
    }
    
    private func point(_ deg: CGFloat) -> CGPoint {
        .init(x: center.x - radius + (deg / period * diameter), y: center.y - (cos(deg / 180 * .pi) * amplitude))
    }
}
