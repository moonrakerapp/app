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
        let time = DateFormatter()
        time.dateStyle = .none
        time.timeStyle = .medium
        
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
