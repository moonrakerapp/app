import AppKit

final class Day: Control {
    let day: Int
    private weak var config: Config!
    private weak var label: Label!
    
    var selected = false {
        didSet {
            label.textColor = selected ? .black : .haze()
            layer!.backgroundColor = selected ? .haze() : .black
        }
    }
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init(_ day: Int, _ config: Config) {
        self.day = day
        self.config = config
        super.init(config, #selector(config.day(_:)))
        setAccessibilityLabel("\(day)")
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true
        layer!.cornerRadius = 20
        
        let label = Label("\(day)", .medium(14), .haze())
        addSubview(label)
        self.label = label
        
        widthAnchor.constraint(equalToConstant: 40).isActive = true
        heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        label.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
    }
}
