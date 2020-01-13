import Moonraker
import Foundation
import Combine
import CoreGraphics
import WatchKit

final class MainModel: ObservableObject {
    @Published var radius = CGFloat()
    @Published private(set) var phase = Phase.new
    @Published private(set) var points = [CGPoint]()
    @Published private(set) var middle = CGPoint.zero
    @Published private(set) var start = CGPoint.zero
    @Published private(set) var center = CGPoint.zero
    @Published private(set) var fraction = CGFloat()
    @Published private(set) var angle = Double()
    @Published private(set) var amplitude = CGFloat()
    @Published private(set) var percent = ""
    @Published private(set) var name = ""
    @Published private(set) var date = ""
    private var azimuth = CGFloat()
    private var altitude = CGFloat()
    private var worldRadius = CGFloat()
    private var sub: AnyCancellable!
    private let period = CGFloat(360)
    
    var zoom = false {
        didSet {
            render()
        }
    }
    
    init() {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        
        let time = DateFormatter()
        time.dateFormat = "h a"
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            self.phase = $0.phase
            self.fraction = .init($0.fraction)
            self.angle = $0.angle
            self.azimuth = .init($0.azimuth)
            self.altitude = .init($0.altitude)
            
            self.render()
            self.percent = "\(Int(round($0.fraction * 1000) / 10))"
            self.name = .key("Phase.\($0.phase)")
            self.date = ""
            if abs(moonraker.offset) > 3600 {
                let day = moonraker.date.addingTimeInterval(moonraker.offset)
                if abs(moonraker.offset) >= 86400 {
                    self.date = formatter.string(from: day) + " - "
                }
                self.date += time.string(from: day)
            }
        }
    }
    
    private func render() {
        let size = WKInterfaceDevice.current().screenBounds.size
        middle = CGPoint(x: size.width / 2, y: (size.height / 2) + 32)
        worldRadius = (min(size.width, size.height) * 0.5) - 2
        amplitude = worldRadius / 3
        start = .init(x: middle.x - worldRadius, y: middle.y + amplitude)
        points = stride(from: 2, through: period, by: 2).map(point(_:))
        center = zoom ? middle : point((azimuth >= 0 ? (.pi * 1.5) - altitude : altitude + (.pi / 2)) * 180 / .pi)
        radius = zoom ? worldRadius / 3 : worldRadius / 8
    }
    
    private func point(_ deg: CGFloat) -> CGPoint {
        .init(x: middle.x - worldRadius + (deg / period * (worldRadius * 2)), y: middle.y + (cos(deg / 180 * .pi) * amplitude))
    }
}
