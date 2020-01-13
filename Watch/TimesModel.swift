import Moonraker
import Foundation
import Combine

final class TimesModel: ObservableObject {
    @Published private(set) var riseDate = ""
    @Published private(set) var riseCounter = ""
    @Published private(set) var setDate = ""
    @Published private(set) var setCounter = ""
    private var sub: AnyCancellable!
    let timer = DispatchSource.makeTimerSource(queue: .main)
    
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
        
        sub = moonraker.times.receive(on: DispatchQueue.main).sink {
            switch $0 {
            case .down:
                self.riseDate = "-"
                self.riseCounter = ""
                self.setDate = NSLocalizedString("Stats.down", comment: "")
            case .up:
                self.riseDate = NSLocalizedString("Stats.up", comment: "")
                self.setDate = "-"
                self.setCounter = ""
            case .rise(let _rise):
                self.riseDate = time.string(from: _rise)
                self.setDate = "-"
                self.setCounter = ""
            case .set(let _set):
                self.riseDate = "-"
                self.riseCounter = ""
                self.setDate = time.string(from: _set)
            case .both(let _rise, let _set):
                self.riseDate = time.string(from: _rise)
                self.setDate = time.string(from: _set)
            }
        }
        
        timer.activate()
        timer.setEventHandler {
            print("tick")
            let now = Date()
            switch moonraker.times.value {
            case .rise(let time):
                self.riseCounter = counter.string(from: now, to: time) ?? ""
            case .set(let time):
                self.setCounter = counter.string(from: now, to: time) ?? ""
            case .both(let _rise, let _set):
                self.riseCounter = counter.string(from: now, to: _rise) ?? ""
                self.setCounter = counter.string(from: now, to: _set) ?? ""
            default: break
            }
        }
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
