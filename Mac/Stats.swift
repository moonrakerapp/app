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
    
    var info: Info! {
        didSet {
            phase.stringValue = .key("Phase.\(info.phase)")
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
        
        let phase = item()
        phase.0.stringValue = .key("Stats.phase")
        self.phase = phase.1
        
        let rise = item()
        self.rise = rise.0
        riseCounter = rise.1
        
        let set = item()
        self.set = set.0
        setCounter = set.1
        
        let full = item()
        full.0.stringValue = .key("Stats.full")
        self.full = full.1
        
        heightAnchor.constraint(equalToConstant: 220).isActive = true
        
        phase.0.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        full.0.topAnchor.constraint(equalTo: phase.2.bottomAnchor, constant: 15).isActive = true
        rise.0.topAnchor.constraint(equalTo: full.2.bottomAnchor, constant: 15).isActive = true
        set.0.topAnchor.constraint(equalTo: rise.2.bottomAnchor, constant: 15).isActive = true
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
    
    private func item() -> (Label, Label, NSView) {
        let title = Label("", .medium(14), .shade())
        title.maximumNumberOfLines = 1
        addSubview(title)
        
        let counter = Label("", .medium(14), .rain())
        counter.maximumNumberOfLines = 1
        addSubview(counter)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .shade(0.3)
        addSubview(border)
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        
        counter.leftAnchor.constraint(equalTo: title.rightAnchor).isActive = true
        counter.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -10).isActive = true
        counter.bottomAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        border.rightAnchor.constraint(equalTo: counter.rightAnchor).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return (title, counter, border)
    }
}
