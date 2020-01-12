import Moonraker
import CoreGraphics

struct Render {
    var radius: CGFloat
    let phase: Phase
    let points: [CGPoint]
    let middle: CGPoint
    let start: CGPoint
    let center: CGPoint
    let fraction: CGFloat
    let angle: Double
    let amplitude: CGFloat
    private static let period = CGFloat(360)
    
    init(_ info: Info, size: CGSize, zoom: Bool) {
        phase = info.phase
        fraction = .init(info.fraction)
        angle = info.angle
        
        let middle = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = (min(size.width, size.height) * 0.5) - 2
        let amplitude = radius / 3
        
        start = .init(x: middle.x - radius, y: middle.y + amplitude)
        points = stride(from: 2, through: Render.period, by: 2).map { Render.point(middle, radius, $0, amplitude) }
        center = zoom ? .init(x: middle.x, y: middle.y - amplitude) :
            Render.point(middle, radius, .init(info.azimuth >= 0 ? (.pi * 1.5) - info.altitude : info.altitude + (.pi / 2)) * 180 / .pi, amplitude)
        self.middle = middle
        self.amplitude = amplitude
        self.radius = zoom ? radius / 3 : radius / 8
    }
    
    private static func point(_ middle: CGPoint, _ radius: CGFloat, _ deg: CGFloat, _ amplitude: CGFloat) -> CGPoint {
        .init(x: middle.x - radius + (deg / period * (radius * 2)), y: middle.y + (cos(deg / 180 * .pi) * amplitude))
    }
}