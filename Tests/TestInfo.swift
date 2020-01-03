@testable import Moonraker
import XCTest

final class TestInfo: XCTestCase {
    private var moonraker: Moonraker!
    
    override func setUp() {
        moonraker = .init()
    }
    
    func testPhase() {
        XCTAssertEqual(.waxingCrescent, moonraker.info(1577905200, 52.483343, 13.452053).phase)
    }
    
    func testFraction() {
        XCTAssertEqual(0.3757901567399345, moonraker.info(1577905200, 52.483343, 13.452053).fraction)
    }
    
    func testAngle() {
        XCTAssertEqual(-2.4005244109413524, moonraker.info(1577905200, 52.483343, 13.452053).angle)
    }
    
    func testAzimuth() {
        XCTAssertEqual(0.772717472163514, moonraker.info(1577905200, 52.483343, 13.452053).azimuth)
    }
    
    func testAltitude() {
        XCTAssertEqual(0.38324885985831264, moonraker.info(1577905200, 52.483343, 13.452053).altitude)
    }
}
