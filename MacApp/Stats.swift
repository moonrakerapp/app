import Moonraker
import AppKit

final class Stats: NSView {
    var times: (Times, Date)! {
        didSet {
            switch times.0 {
            case .down:
                riseTime.stringValue = "-"
                setTime.stringValue = .key("Stats.down")
            case .up:
                riseTime.stringValue = .key("Stats.up")
                setTime.stringValue = "-"
            case .rise(let time):
                riseTime.stringValue = timer.string(from: time)
                setTime.stringValue = "-"
            case .set(let time):
                riseTime.stringValue = "-"
                setTime.stringValue = timer.string(from: time)
            case .both(let rise, let set):
                riseTime.stringValue = timer.string(from: rise)
                setTime.stringValue = timer.string(from: set)
            }
            fullTime.stringValue = dater.string(from: times.1)
            riseCounter.stringValue = ""
            setCounter.stringValue = ""
            fullCounter.stringValue = ""
        }
    }
    
    private weak var riseTime: Label!
    private weak var riseCounter: Label!
    private weak var setTime: Label!
    private weak var setCounter: Label!
    private weak var fullTime: Label!
    private weak var fullCounter: Label!
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
        dater.dateStyle = .medium
        dater.timeStyle = .none
        
        let rise = item(.key("Stats.rise"))
        riseTime = rise.1
        riseCounter = rise.2
        
        let set = item(.key("Stats.set"))
        setTime = set.1
        setCounter = set.2
        
        let full = item(.key("Stats.full"))
        fullTime = full.1
        fullCounter = full.2
        
        heightAnchor.constraint(equalToConstant: 160).isActive = true
        
        rise.0.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        set.0.topAnchor.constraint(equalTo: rise.3.bottomAnchor, constant: 15).isActive = true
        full.0.topAnchor.constraint(equalTo: set.3.bottomAnchor, constant: 15).isActive = true
    }
    
    func tick() {
        guard let times = self.times else { return }
        let now = Date()
        switch times.0 {
        case .rise(let time):
            riseCounter.stringValue = .key("Stats.in") + (relative.string(from: now, to: time) ?? "")
        case .set(let time):
            setCounter.stringValue = .key("Stats.in") + (relative.string(from: now, to: time) ?? "")
        case .both(let rise, let set):
            riseCounter.stringValue = .key("Stats.in") + (relative.string(from: now, to: rise) ?? "")
            setCounter.stringValue = .key("Stats.in") + (relative.string(from: now, to: set) ?? "")
        default: break
        }
        fullCounter.stringValue = .key("Stats.in") + (relative.string(from: now, to: times.1) ?? "")
    }
    
    private func item(_ title: String) -> (Label, Label, Label, NSView) {
        let title = Label(title, .medium(14), .shade())
        title.maximumNumberOfLines = 1
        addSubview(title)
        
        let time = Label("", .light(14), .rain())
        time.maximumNumberOfLines = 1
        addSubview(time)
        
        let counter = Label("", .light(14), .shade())
        counter.maximumNumberOfLines = 1
        addSubview(counter)
        
        let border = NSView()
        border.translatesAutoresizingMaskIntoConstraints = false
        border.wantsLayer = true
        border.layer!.backgroundColor = .shade(0.3)
        addSubview(border)
        
        title.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        title.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -40).isActive = true
        
        time.leftAnchor.constraint(equalTo: title.rightAnchor, constant: 10).isActive = true
        time.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -40).isActive = true
        time.bottomAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        
        counter.leftAnchor.constraint(equalTo: time.rightAnchor).isActive = true
        counter.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor, constant: -40).isActive = true
        counter.bottomAnchor.constraint(equalTo: title.bottomAnchor).isActive = true
        
        border.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 40).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: -40).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return (title, time, counter, border)
    }
}
