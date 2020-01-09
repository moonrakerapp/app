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
        
        let phase = Label("", .medium(18), .haze())
        addSubview(phase)
        
        let percent = Label([])
        addSubview(percent)
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            phase.text = .key("Phase.\($0.phase)")
            percent.attributed([("\(Int(round($0.fraction * 1000) / 10))", .bold(20), .haze()), ("%", .regular(14), .shade())])
        }
        
        widthAnchor.constraint(equalToConstant: 220).isActive = true
        bottomAnchor.constraint(equalTo: percent.bottomAnchor, constant: 5).isActive = true
        
        phase.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        phase.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        percent.topAnchor.constraint(equalTo: phase.bottomAnchor, constant: 5).isActive = true
        percent.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 2).isActive = true
    }
}
