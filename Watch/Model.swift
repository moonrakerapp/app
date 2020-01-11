import Moonraker
import Foundation
import Combine

final class Model: ObservableObject {
    @Published var info: Info?
    private var sub: AnyCancellable!
    private let moonraker = Moonraker()
    
    init() {
        sub = moonraker.info.receive(on: DispatchQueue.main).sink {
            self.info = $0
        }
    }
}
