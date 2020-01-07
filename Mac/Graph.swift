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
        
        let phase = Label("", .medium(16), .haze())
        addSubview(phase)
        
        let percent = Label([])
        addSubview(percent)
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            phase.stringValue = .key("Phase.\($0.phase)")
            percent.attributed([("\(Int(round($0.fraction * 100)))", .bold(16), .haze()), ("%", .regular(12), .shade())])
        }
        
        widthAnchor.constraint(equalToConstant: 220).isActive = true
        bottomAnchor.constraint(equalTo: percent.bottomAnchor, constant: 5).isActive = true
        
        phase.topAnchor.constraint(equalTo: topAnchor, constant: 5).isActive = true
        phase.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        percent.topAnchor.constraint(equalTo: phase.bottomAnchor, constant: 5).isActive = true
        percent.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 2).isActive = true
    }
}
