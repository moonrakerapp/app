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
        
        let phase = Label("", .bold(18), .haze())
        addSubview(phase)
        
        let percent = Label([])
        addSubview(percent)
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            phase.stringValue = .key("Phase.\($0.phase)")
            percent.attributed([("\(Int($0.fraction * 100))", .bold(18), .haze()), ("%", .regular(14), .shade())])
        }
        
        phase.bottomAnchor.constraint(equalTo: percent.topAnchor).isActive = true
        phase.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 10).isActive = true
        phase.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
        percent.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 10).isActive = true
        percent.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        percent.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
    }
}
