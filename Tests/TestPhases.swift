@testable import Moonraker
import XCTest

final class TestPhases: XCTestCase {
    private var moonraker: Moonraker!
    
    override func setUp() {
        moonraker = .init()
    }
    
    func testRise() {
        XCTAssertEqual(1578644990, Int(moonraker.full(1577905200).timeIntervalSince1970))
    }
}
