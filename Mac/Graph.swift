import Moonraker
import AppKit

final class Graph: NSView {
    var info: Info! {
        didSet {
            phase.stringValue = .key("Phase.\(info.phase)")
            percent.attributed([("\(Int(info.fraction * 100))", .bold(20), .haze()), ("%", .regular(14), .shade())])
        }
    }
    
    private weak var phase: Label!
    private weak var percent: Label!
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let phase = Label("", .bold(20), .haze())
        addSubview(phase)
        self.phase = phase
        
        let percent = Label("", .bold(30), .rain())
        addSubview(percent)
        self.percent = percent
        
        let illumination = Label(.key("Graph.illumination"), .regular(14), .shade())
        addSubview(illumination)
        
        phase.bottomAnchor.constraint(equalTo: percent.topAnchor).isActive = true
        phase.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 10).isActive = true
        phase.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
        percent.bottomAnchor.constraint(equalTo: illumination.topAnchor).isActive = true
        percent.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 10).isActive = true
        percent.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        
        illumination.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 10).isActive = true
        illumination.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        illumination.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
    }
}
