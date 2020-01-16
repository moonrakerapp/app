import Moonraker
import QuartzCore
import Combine

final class Equalizer: CAShapeLayer {
    private var sub: AnyCancellable!
    
    required init?(coder: NSCoder) { nil }
    override init() {
        super.init()
        fillColor = .clear
        strokeColor = .shade()
        lineWidth = 1
        lineCap = .round
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            let point = (CGFloat($0.azimuth >= 0 ? (.pi * 1.5) - $0.altitude : $0.altitude + (.pi / 2)) / (.pi * 2)) * 29
            let path = CGMutablePath()
            (0 ..< 30).forEach {
                let i = CGFloat($0)
                let delta = 4 / max(abs(i - point), 0.2)
                path.addPath({
                    $0.move(to: .init(x: 5 + (i * 5), y: 40 - delta))
                    $0.addLine(to: .init(x: 5 + (i * 5), y: 40 + delta))
                    return $0
                } (CGMutablePath()))
            }
            
            let animation = CABasicAnimation(keyPath: "path")
            animation.duration = 0.35
            animation.fromValue = self.path
            animation.toValue = path
            animation.timingFunction = .init(name: .easeOut)
            self.path = path
            self.add(animation, forKey: "path")
        }
    }
}
