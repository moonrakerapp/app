import Moonraker
import AppKit
import Combine

final class Graph: NSView {
    private var sub: AnyCancellable!
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let base = CAShapeLayer()
        base.fillColor = .clear
        base.lineWidth = 4
        base.strokeColor = .shade(0.4)
        base.lineCap = .round
        base.path = {
            $0.addArc(center: .init(x: 120, y: 105), radius: 35, startAngle: .pi * 1.25, endAngle: .pi * -0.25, clockwise: true)
            return $0
        } (CGMutablePath())
        layer = base
        wantsLayer = true
        
        let ring = CAShapeLayer()
        ring.fillColor = .clear
        ring.lineWidth = 6
        ring.strokeColor = .haze()
        ring.lineCap = .round
        ring.path = base.path
        ring.strokeEnd = 0
        base.addSublayer(ring)
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        
        let time = DateFormatter()
        time.locale = .init(identifier: "en_US_POSIX")
        time.dateFormat = "h a"
        
        let label = Label([])
        label.maximumNumberOfLines = 6
        addSubview(label)
        
        sub = moonraker.travel.receive(on: DispatchQueue.main).sink {
            ring.strokeEnd = .init($0.fraction)
            
            var attributed: [(String, NSFont, NSColor)] = [
                ("\(Int(round($0.fraction * 1000) / 10))", .bold(20), .haze()), ("%", .regular(14), .shade()),
                ("\n\n" + .key("Phase.\($0.phase)") + "\n\n", .regular(14), .haze())]
            if abs(moonraker.offset) > 3600 {
                let date = moonraker.date.addingTimeInterval(moonraker.offset)
                if abs(moonraker.offset) >= 86400 {
                    attributed.append((formatter.string(from: date), .medium(12), .shade()))
                }
                attributed.append(("\n" + time.string(from: date), .medium(12), .shade()))
            }
            label.attributed(attributed, align: .center)
        }
        
        widthAnchor.constraint(equalToConstant: 240).isActive = true
        heightAnchor.constraint(equalToConstant: 150).isActive = true

        label.topAnchor.constraint(equalTo: topAnchor, constant: 35).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
