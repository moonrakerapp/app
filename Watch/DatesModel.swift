import Moonraker
import Foundation
import Combine

final class DatesModel: ObservableObject {
    @Published private(set) var info: Info?
    @Published private(set) var percent = ""
    @Published private(set) var name = ""
    @Published private(set) var date = ""
    private var sub: AnyCancellable!
    private let timer = DispatchSource.makeTimerSource(queue: .main)
    
    init() {
        let counter = DateComponentsFormatter()
        let remains = DateComponentsFormatter()
        remains.allowedUnits = [.month, .weekOfMonth, .day]
        
        let date = DateFormatter()
        date.dateStyle = .short
        date.timeStyle = .none
        
        let time = DateFormatter()
        time.dateStyle = .none
        time.timeStyle = .medium
        
    }
}


/*
 

 
 let outside = Button(self, #selector(close))
 view.addSubview(outside)
 
 let base = UIView()
 base.backgroundColor = .black
 base.translatesAutoresizingMaskIntoConstraints = false
 view.addSubview(base)
 
 let _close = Button(self, #selector(close))
 view.addSubview(_close)
 
 let icon = Image("close")
 _close.addSubview(icon)
 
 let border = UIView()
 border.translatesAutoresizingMaskIntoConstraints = false
 border.isUserInteractionEnabled = false
 border.backgroundColor = .shade(0.3)
 view.addSubview(border)
 
 let rise = Stat("rise")
 rise.accessibilityLabel = .key("Stats.rise")
 base.addSubview(rise)
 
 let set = Stat("set")
 set.accessibilityLabel = .key("Stats.set")
 base.addSubview(set)
 
 let new = Stat("new")
 new.accessibilityLabel = .key("Stats.new")
 base.addSubview(new)
 
 let full = Stat("full")
 full.accessibilityLabel = .key("Stats.full")
 base.addSubview(full)
 
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
 
 */
