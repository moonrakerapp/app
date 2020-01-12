import Moonraker
import CoreGraphics

struct ViewModel {
    let phase: Phase
    let points: [CGPoint]
    let start: CGPoint
    let center: CGPoint
    let radius: CGFloat
    let fraction: CGFloat
    let ratio: CGFloat
    private static let period = CGFloat(360)
    
    init(_ info: Info, size: CGSize, ratio: CGFloat, zoom: Bool) {
        phase = info.phase
        fraction = .init(info.fraction)
        self.ratio = ratio
        
        let middle = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = (min(size.width, size.height) * 0.5) - 2
        let amplitude = radius / 3
        start = .init(x: middle.x - radius, y: middle.y + (amplitude * ratio))
        points = stride(from: 2, through: ViewModel.period, by: 2).map { ViewModel.point(middle, radius, $0, amplitude, ratio) }
        center = zoom ? middle :
            ViewModel.point(middle, radius,
                            .init(info.azimuth >= 0 ? (.pi * 1.5) - info.altitude : info.altitude + (.pi / 2)) * 180 / .pi,
                            amplitude, ratio)
        self.radius = zoom ? radius / 2 : radius / 5
    }
    
    private static func point(_ middle: CGPoint, _ radius: CGFloat, _ deg: CGFloat, _ amplitude: CGFloat, _ ratio: CGFloat) -> CGPoint {
        .init(x: middle.x - radius + (deg / period * (radius * 2)), y: middle.y + (cos(deg / 180 * .pi) * (amplitude * ratio)))
    }
}
