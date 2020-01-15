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
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        
        let time = DateFormatter()
        time.locale = .init(identifier: "en_US_POSIX")
        time.dateFormat = "h a"
        
        let label = Label([])
        label.maximumNumberOfLines = 5
        addSubview(label)
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            var attributed: [(String, NSFont, NSColor)] = [
                ("\(Int(round($0.fraction * 1000) / 10))", .bold(20), .haze()), ("%", .regular(14), .shade()),
                ("\n" + .key("Phase.\($0.phase)") + "\n\n", .regular(16), .haze())]
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
        heightAnchor.constraint(equalToConstant: 115).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
