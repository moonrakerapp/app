@testable import Moonraker
import XCTest

final class TestPhases: XCTestCase {
    private var moonraker: Moonraker!
    
    override func setUp() {
        moonraker = .init()
    }
    
    func testFull() {
        XCTAssertEqual(1578644990, Int(moonraker.phases(1577905200).1.timeIntervalSince1970))
    }
    
    func testNew() {
        XCTAssertEqual(1579920686, Int(moonraker.phases(1577905200).0.timeIntervalSince1970))
    }
    
    func testRoundFull() {
        XCTAssertEqual(.full, moonraker.phase(0.491))
    }
    
    func testRoundNew() {
        XCTAssertEqual(.new, moonraker.phase(0.009))
    }
}
