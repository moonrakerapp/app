import Moonraker
import AppKit

final class Stats: NSView {
    var times: Times! {
        didSet {
            switch times! {
            case .down:
                rise.stringValue = .key("Stats.rise") + " -"
                riseCounter.stringValue = ""
                set.stringValue = .key("Stats.down")
            case .up:
                rise.stringValue = .key("Stats.up")
                set.stringValue = .key("Stats.set") + " -"
                setCounter.stringValue = ""
            case .rise(let time):
                rise.stringValue = .key("Stats.rise") + " " + timer.string(from: time)
                set.stringValue = .key("Stats.set") + " -"
                setCounter.stringValue = ""
            case .set(let time):
                rise.stringValue = .key("Stats.rise") + " -"
                riseCounter.stringValue = ""
                set.stringValue = .key("Stats.set") + " " + timer.string(from: time)
            case .both(let _rise, let _set):
                rise.stringValue = .key("Stats.rise") + " " + timer.string(from: _rise)
                set.stringValue = .key("Stats.set") + " " + timer.string(from: _set)
            }
        }
    }
    
    private weak var rise: Label!
    private weak var riseCounter: Label!
    private weak var set: Label!
    private weak var setCounter: Label!
    private let timer = DateFormatter()
    private let relative = DateComponentsFormatter()
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        timer.dateStyle = .none
        timer.timeStyle = .medium
        
        let rise = item()
        self.rise = rise.0
        riseCounter = rise.1
        
        let set = item()
        self.set = set.0
        setCounter = set.1
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .shade(0.4)
        addSubview(border)
        
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        rise.0.bottomAnchor.constraint(equalTo: border.topAnchor, constant: -5).isActive = true
        set.0.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        
        border.bottomAnchor.constraint(equalTo: set.0.topAnchor, constant: -5).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.rightAnchor.constraint(greaterThanOrEqualTo: rise.1.rightAnchor).isActive = true
        border.rightAnchor.constraint(greaterThanOrEqualTo: set.1.rightAnchor).isActive = true
    }
    
    func tick() {
        guard let times = self.times else { return }
        let now = Date()
        switch times {
        case .rise(let time):
            riseCounter.stringValue = relative.string(from: now, to: time) ?? ""
        case .set(let time):
            setCounter.stringValue = relative.string(from: now, to: time) ?? ""
        case .both(let rise, let set):
            riseCounter.stringValue = relative.string(from: now, to: rise) ?? ""
            setCounter.stringValue = relative.string(from: now, to: set) ?? ""
        default: break
        }
    }
    
    private func item() -> (Label, Label) {
        let title = Label("", .bold(14), .shade())
        addSubview(title)
        
        let counter = Label("", .regular(14), .rain())
        addSubview(counter)
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        
        counter.leftAnchor.constraint(equalTo: title.rightAnchor).isActive = true
        counter.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        counter.bottomAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        
        return (title, counter)
    }
}
