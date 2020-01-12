import Moonraker
import Foundation
import Combine

final class Model: ObservableObject {
    @Published private(set) var info: Info?
    @Published private(set) var percent = ""
    @Published private(set) var name = ""
    @Published private(set) var date = ""
    private var sub: AnyCancellable!
    
    init() {
        let formatter = DateFormatter()
        formatter.timeStyle = .none
        formatter.dateStyle = .short
        
        let time = DateFormatter()
        time.dateFormat = "h a"
        
        sub = moonraker.info.receive(on: DispatchQueue.main).sink { [weak self] in
            self?.info = $0
            self?.percent = "\(Int(round($0.fraction * 1000) / 10))"
            self?.name = NSLocalizedString("Phase.\($0.phase)", comment: "")
            if abs(moonraker.offset) > 3600 || true {
                let day = moonraker.date.addingTimeInterval(moonraker.offset)
                if abs(moonraker.offset) >= 86400 || true {
                    self?.date = formatter.string(from: day) + " "
                } else {
                    self?.date = ""
                }
                self?.date += time.string(from: day)
            }
        }
    }
}
