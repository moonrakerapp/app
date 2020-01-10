import Moonraker
import UIKit
import Combine

final class Graph: UIView {
    private var sub: AnyCancellable!
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = false
        translatesAutoresizingMaskIntoConstraints = false
        
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        
        let time = DateFormatter()
        time.dateFormat = "h a"
        
        let label = Label([])
        label.numberOfLines = 5
        addSubview(label)
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            var attributed: [(String, UIFont, UIColor)] = [
                ("\(Int(round($0.fraction * 1000) / 10))", .bold(20), .haze()), ("%", .regular(14), .shade()),
                ("\n" + .key("Phase.\($0.phase)") + "\n\n", .medium(18), .haze())]
            if abs(moonraker.offset) > 3600 {
                let date = moonraker.date.addingTimeInterval(moonraker.offset)
                if abs(moonraker.offset) >= 86400 {
                    attributed.append((formatter.string(from: date), .medium(14), .shade()))
                }
                attributed.append(("\n" + time.string(from: date), .medium(14), .shade()))
            }
            label.attributed(attributed, align: .center)
        }
        
        widthAnchor.constraint(equalToConstant: 200).isActive = true
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        label.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
