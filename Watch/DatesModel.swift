import Foundation
import Combine

final class DatesModel: ObservableObject {
    @Published private(set) var newDate = ""
    @Published private(set) var newCounter = ""
    @Published private(set) var fullDate = ""
    @Published private(set) var fullCounter = ""
    private var sub: AnyCancellable!
    
    init() {
        let remains = DateComponentsFormatter()
        remains.allowedUnits = [.month, .weekOfMonth, .day]
        
        let date = DateFormatter()
        date.dateStyle = .short
        date.timeStyle = .none
        
        sub = app.moonraker.phases.receive(on: DispatchQueue.main).sink {
            let now = Date()
            if Calendar.current.date(byAdding: .hour, value: -23, to: $0.0)! < now {
                self.newDate = .key("Stats.now")
                self.newCounter = ""
            } else {
                self.newDate = date.string(from: $0.0)
                self.newCounter = remains.string(from: now, to: $0.0) ?? ""
            }
            
            if Calendar.current.date(byAdding: .hour, value: -23, to: $0.1)! < now {
                self.fullDate = .key("Stats.now")
                self.fullCounter = ""
            } else {
                self.fullDate = date.string(from: $0.1)
                self.fullCounter = remains.string(from: now, to: $0.1) ?? ""
            }
        }
    }
}
