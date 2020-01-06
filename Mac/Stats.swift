import Moonraker
import AppKit

final class Stats: NSView {
    var times: (Times, Date)! {
        didSet {
            switch times.0 {
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
            full.stringValue = dater.string(from: times.1)
        }
    }
    
    private weak var phase: Label!
    private weak var rise: Label!
    private weak var riseCounter: Label!
    private weak var set: Label!
    private weak var setCounter: Label!
    private weak var full: Label!
    private let timer = DateFormatter()
    private let dater = DateFormatter()
    private let relative = DateComponentsFormatter()
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        timer.dateStyle = .none
        timer.timeStyle = .medium
        dater.dateFormat = "EEEE, MMMM d"
        
        let rise = item()
        self.rise = rise.0
        riseCounter = rise.1
        
        let set = item()
        self.set = set.0
        setCounter = set.1
        
        let full = item()
        full.0.stringValue = .key("Stats.full")
        self.full = full.1
        
        let top = NSView()
        top.translatesAutoresizingMaskIntoConstraints = false
        top.wantsLayer = true
        top.layer!.backgroundColor = .shade(0.4)
        addSubview(top)
        
        let bottom = NSView()
        bottom.translatesAutoresizingMaskIntoConstraints = false
        bottom.wantsLayer = true
        bottom.layer!.backgroundColor = .shade(0.4)
        addSubview(bottom)
        
        heightAnchor.constraint(equalToConstant: 130).isActive = true
        
        full.0.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40).isActive = true
        rise.0.bottomAnchor.constraint(equalTo: top.topAnchor, constant: -5).isActive = true
        set.0.bottomAnchor.constraint(equalTo: bottom.topAnchor, constant: -5).isActive = true
        
        top.bottomAnchor.constraint(equalTo: set.0.topAnchor, constant: -5).isActive = true
        top.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        top.rightAnchor.constraint(equalTo: rise.1.rightAnchor).isActive = true
        top.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        bottom.bottomAnchor.constraint(equalTo: full.0.topAnchor, constant: -5).isActive = true
        bottom.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        bottom.rightAnchor.constraint(equalTo: set.1.rightAnchor).isActive = true
        bottom.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    func tick() {
        guard let times = self.times else { return }
        let now = Date()
        switch times.0 {
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
