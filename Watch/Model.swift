import Moonraker
import Foundation
import Combine

final class Model: ObservableObject {
    @Published private(set) var info: Info?
    private var sub: AnyCancellable!
    
    init() {
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            self.info = $0
        }
    }
}
