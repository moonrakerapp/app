import Moonraker
import AppKit
import Combine

final class Stats: NSView {
    private var sub: AnyCancellable!
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let counter = DateComponentsFormatter()
        let date = DateFormatter()
        date.dateStyle = .none
        date.timeStyle = .medium
        
        let rise = Stat("rise")
        rise.setAccessibilityLabel(.key("Stats.rise"))
        addSubview(rise)
        
        let set = Stat("set")
        set.setAccessibilityLabel(.key("Stats.set"))
        addSubview(set)
        
        let new = Stat("new")
        new.setAccessibilityLabel(.key("Stats.new"))
        addSubview(new)
        
        let full = Stat("full")
        full.setAccessibilityLabel(.key("Stats.full"))
        addSubview(full)
        
        sub = moonraker.times.receive(on: DispatchQueue.main).sink {
            switch $0 {
            case .down:
                rise.date.stringValue = "-"
                rise.counter.stringValue = ""
                set.date.stringValue = .key("Stats.down")
            case .up:
                rise.date.stringValue = .key("Stats.up")
                set.date.stringValue = "-"
                set.counter.stringValue = ""
            case .rise(let _rise):
                rise.date.stringValue = date.string(from: _rise)
                set.date.stringValue = "-"
                set.counter.stringValue = ""
            case .set(let _set):
                rise.date.stringValue = .key("Stats.rise") + " -"
                rise.counter.stringValue = ""
                set.date.stringValue = date.string(from: _set)
            case .both(let _rise, let _set):
                rise.date.stringValue = date.string(from: _rise)
                set.date.stringValue = date.string(from: _set)
            }
        }
        
        timer.activate()
        timer.schedule(deadline: .now(), repeating: 1)
        timer.setEventHandler {
            let now = Date()
            switch moonraker.times.value {
            case .rise(let time):
                rise.counter.stringValue = counter.string(from: now, to: time) ?? ""
            case .set(let time):
                set.counter.stringValue = counter.string(from: now, to: time) ?? ""
            case .both(let _rise, let _set):
                rise.counter.stringValue = counter.string(from: now, to: _rise) ?? ""
                set.counter.stringValue = counter.string(from: now, to: _set) ?? ""
            default: break
            }
        }
        
        heightAnchor.constraint(equalToConstant: 140).isActive = true
        
        rise.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        let left = rise.leftAnchor.constraint(equalTo: leftAnchor, constant: 40)
        left.priority = .defaultLow
        left.isActive = true
        
        set.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        set.leftAnchor.constraint(equalTo: rise.rightAnchor).isActive = true
        set.rightAnchor.constraint(lessThanOrEqualTo: centerXAnchor).isActive = true
        
        new.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        new.rightAnchor.constraint(equalTo: full.leftAnchor).isActive = true
        new.leftAnchor.constraint(greaterThanOrEqualTo: centerXAnchor).isActive = true
        
        full.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        let right = full.rightAnchor.constraint(equalTo: rightAnchor, constant: -40)
        right.priority = .defaultLow
        right.isActive = true
    }
}
