import Moonraker
import UIKit
import Combine

final class Stats: UIView {
    private var times: AnyCancellable!
    private var phases: AnyCancellable!
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    required init?(coder: NSCoder) { nil }
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        
        let counter = DateComponentsFormatter()
        let remains = DateComponentsFormatter()
        remains.allowedUnits = [.month, .weekOfMonth, .day]
        
        let date = DateFormatter()
        date.dateStyle = .short
        date.timeStyle = .none
        
        let time = DateFormatter()
        time.dateStyle = .none
        time.timeStyle = .medium
        
        let rise = Stat("rise")
        rise.accessibilityLabel = .key("Stats.rise")
        addSubview(rise)
        
        let set = Stat("set")
        set.accessibilityLabel = .key("Stats.set")
        addSubview(set)
        
        let new = Stat("new")
        new.accessibilityLabel = .key("Stats.new")
        addSubview(new)
        
        let full = Stat("full")
        full.accessibilityLabel = .key("Stats.full")
        addSubview(full)
        
        times = moonraker.times.receive(on: DispatchQueue.main).sink {
            switch $0 {
            case .down:
                rise.date.text = "-"
                rise.counter.text = ""
                set.date.text = .key("Stats.down")
            case .up:
                rise.date.text = .key("Stats.up")
                set.date.text = "-"
                set.counter.text = ""
            case .rise(let _rise):
                rise.date.text = time.string(from: _rise)
                set.date.text = "-"
                set.counter.text = ""
            case .set(let _set):
                rise.date.text = .key("Stats.rise") + " -"
                rise.counter.text = ""
                set.date.text = time.string(from: _set)
            case .both(let _rise, let _set):
                rise.date.text = time.string(from: _rise)
                set.date.text = time.string(from: _set)
            }
        }
        
        phases = moonraker.phases.receive(on: DispatchQueue.main).sink {
            let now = Date()
            if Calendar.current.date(byAdding: .hour, value: -23, to: $0.0)! < now {
                new.date.text = .key("Stats.now")
                new.counter.text = ""
            } else {
                new.date.text = date.string(from: $0.0)
                new.counter.text = remains.string(from: now, to: $0.0) ?? ""
            }
            
            if Calendar.current.date(byAdding: .hour, value: -23, to: $0.1)! < now {
                full.date.text = .key("Stats.now")
                full.counter.text = ""
            } else {
                full.date.text = date.string(from: $0.1)
                full.counter.text = remains.string(from: now, to: $0.1) ?? ""
            }
        }
        
        timer.activate()
        timer.schedule(deadline: .now(), repeating: 1)
        timer.setEventHandler {
            let now = Date()
            switch moonraker.times.value {
            case .rise(let time):
                rise.counter.text = counter.string(from: now, to: time) ?? ""
            case .set(let time):
                set.counter.text = counter.string(from: now, to: time) ?? ""
            case .both(let _rise, let _set):
                rise.counter.text = counter.string(from: now, to: _rise) ?? ""
                set.counter.text = counter.string(from: now, to: _set) ?? ""
            default: break
            }
        }
        
        heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        rise.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        rise.rightAnchor.constraint(equalTo: set.leftAnchor).isActive = true
        
        set.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        set.rightAnchor.constraint(equalTo: centerXAnchor, constant: -5).isActive = true
        
        new.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        new.leftAnchor.constraint(equalTo: centerXAnchor, constant: 5).isActive = true
        
        full.topAnchor.constraint(equalTo: topAnchor, constant: 20).isActive = true
        full.leftAnchor.constraint(equalTo: new.rightAnchor).isActive = true
    }
}
