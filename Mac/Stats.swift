import Moonraker
import AppKit
import Combine

final class Stats: NSView {
    private var times: AnyCancellable!
    private var phases: AnyCancellable!
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    override var mouseDownCanMoveWindow: Bool { false }
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        let counter = RelativeDateTimeFormatter()
        let remains = DateComponentsFormatter()
        remains.allowedUnits = [.month, .weekOfMonth, .day]
        
        let date = DateFormatter()
        date.dateFormat = "d/M"
        
        let time = DateFormatter()
        time.dateFormat = "HH:mm"
        
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
        
        times = moonraker.times.receive(on: DispatchQueue.main).sink {
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
                rise.date.stringValue = time.string(from: _rise)
                set.date.stringValue = "-"
                set.counter.stringValue = ""
            case .set(let _set):
                rise.date.stringValue = .key("Stats.rise") + " -"
                rise.counter.stringValue = ""
                set.date.stringValue = time.string(from: _set)
            case .both(let _rise, let _set):
                rise.date.stringValue = time.string(from: _rise)
                set.date.stringValue = time.string(from: _set)
            }
        }
        
        phases = moonraker.phases.receive(on: DispatchQueue.main).sink {
            let now = Date()
            if Calendar.current.date(byAdding: .hour, value: -23, to: $0.0)! < now {
                new.date.stringValue = .key("Stats.now")
                new.counter.stringValue = ""
            } else {
                new.date.stringValue = date.string(from: $0.0)
                new.counter.stringValue = remains.string(from: now, to: $0.0) ?? ""
            }
            
            if Calendar.current.date(byAdding: .hour, value: -23, to: $0.1)! < now {
                full.date.stringValue = .key("Stats.now")
                full.counter.stringValue = ""
            } else {
                full.date.stringValue = date.string(from: $0.1)
                full.counter.stringValue = remains.string(from: now, to: $0.1) ?? ""
            }
        }
        
        timer.activate()
        timer.schedule(deadline: .now(), repeating: 30)
        timer.setEventHandler {
            let now = Date()
            switch moonraker.times.value {
            case .rise(let time):
                rise.counter.stringValue = counter.localizedString(for: time, relativeTo: now)
            case .set(let time):
                set.counter.stringValue = counter.localizedString(for: time, relativeTo: now)
            case .both(let _rise, let _set):
                rise.counter.stringValue = counter.localizedString(for: _rise, relativeTo: now)
                set.counter.stringValue = counter.localizedString(for: _set, relativeTo: now)
            default: break
            }
        }
        
        heightAnchor.constraint(equalToConstant: 150).isActive = true
        
        rise.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        rise.rightAnchor.constraint(equalTo: set.leftAnchor).isActive = true
        
        set.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        set.leftAnchor.constraint(equalTo: rise.rightAnchor).isActive = true
        set.rightAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        new.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        new.leftAnchor.constraint(equalTo: centerXAnchor).isActive = true
        
        full.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        full.leftAnchor.constraint(equalTo: new.rightAnchor).isActive = true
    }
}
