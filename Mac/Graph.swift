import Moonraker
import AppKit

final class Graph: NSView {
    var info: Info! {
        didSet {
            percent.attributed([("\(Int(info.fraction * 100))", .bold(30), .rain()), ("%", .medium(16), .shade())])
        }
    }
    
    private weak var percent: Label!
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        
        let percent = Label("", .bold(30), .rain())
        percent.maximumNumberOfLines = 1
        addSubview(percent)
        self.percent = percent
        
        let illumination = Label(.key("Graph.illumination"), .medium(14), .shade())
        illumination.maximumNumberOfLines = 1
        addSubview(illumination)
        
        percent.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        percent.bottomAnchor.constraint(equalTo: centerYAnchor).isActive = true
        percent.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 10).isActive = true
        percent.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -40).isActive = true
        
        illumination.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        illumination.leftAnchor.constraint(greaterThanOrEqualTo: leftAnchor, constant: 10).isActive = true
        illumination.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -40).isActive = true
        illumination.topAnchor.constraint(equalTo: percent.bottomAnchor).isActive = true
    }
}
