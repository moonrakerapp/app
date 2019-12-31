import Foundation
import Combine

public final class Moonraker {
    public let subject = CurrentValueSubject<Double, Never>(0)
    
    public init() {
        DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 5) {
            self.subject.send(0.3)
        }
    }
}
