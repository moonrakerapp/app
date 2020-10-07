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
        let counter = RelativeDateTimeFormatter()
        counter.unitsStyle = .short
        let time = DateFormatter()
        time.dateFormat = "HH:mm"
        
        sub = app.moonraker.times.receive(on: DispatchQueue.main).sink {
            switch $0 {
            case .down:
                self.riseDate = "-"
                self.riseCounter = ""
                self.setDate = .key("Stats.down")
            case .up:
                self.riseDate = .key("Stats.up")
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
            let now = Date()
            switch app.moonraker.times.value {
            case .rise(let time):
                self.riseCounter = counter.localizedString(for: time, relativeTo: now)
            case .set(let time):
                self.setCounter = counter.localizedString(for: time, relativeTo: now)
            case .both(let _rise, let _set):
                self.riseCounter = counter.localizedString(for: _rise, relativeTo: now)
                self.setCounter = counter.localizedString(for: _set, relativeTo: now)
            default: break
            }
        }
    }
}
