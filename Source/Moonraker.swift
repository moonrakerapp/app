import Combine

public final class Moonraker {
    public let subject = CurrentValueSubject<Double, Never>(0)
    private let publisher: AnyPublisher<Double, Never>
    
    public init() {
        publisher = subject.eraseToAnyPublisher()


//        let subscriber1 = publisher.sink(receiveValue: { value in
//            print(value)
//        })
//
//        //subscriber1 will recive the events but not the subscriber2
//        subject.send("Event1")
//        subject.send("Event2")
//
//
//        let subscriber2 = publisher.sink(receiveValue: { value in
//            print(value)
//        })
//        //Subscriber1 and Subscriber2 will recive this event
//        subject.send("Event3")
    }
}
