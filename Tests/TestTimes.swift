@testable import Moonraker
import XCTest

final class TestTimes: XCTestCase {
    private var moonraker: Moonraker!
    
    override func setUp() {
        moonraker = .init()
    }
    
    func testRise() {
        switch moonraker.times(.init(timeIntervalSince1970: 1577905200), 52.483343, 13.452053) {
        case .both(let rise, let set):
            XCTAssertEqual(1577962687, Int(rise.timeIntervalSince1970))
            XCTAssertEqual(1577915673, Int(set.timeIntervalSince1970))
        default: XCTFail()
        }
    }
}
