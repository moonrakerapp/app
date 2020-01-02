@testable import Moonraker
import XCTest

final class TestPosition: XCTestCase {
    private var moonraker: Moonraker!
    
    override func setUp() {
        moonraker = .init()
    }
    
    func testAzimuth() {
        XCTAssertEqual(0.772717472163514, moonraker.position(1577905200, 52.483343, 13.452053).0)
    }
    
    func testAltitude() {
        XCTAssertEqual(0.38324885985831264, moonraker.position(1577905200, 52.483343, 13.452053).1)
    }
    
    func testDistance() {
        XCTAssertEqual(405899.2827558138, moonraker.position(1577905200, 52.483343, 13.452053).2)
    }
    
    func testParallaticAngle() {
        XCTAssertEqual(0.4418920291988399, moonraker.position(1577905200, 52.483343, 13.452053).3)
    }
    
    func testSiderealTime() {
        XCTAssertEqual(31507.062909246473, moonraker.siderealTime(5000, -0.23478261600278075))
    }
    
    func testAltitudeStandalone() {
        XCTAssertEqual(0.4125957008354875, moonraker.altitude(-0.2, 0.916007137803518, -0.22925186514190146))
    }
    
    func testAzimuthStandalone() {
        XCTAssertEqual(-0.2127966145322103, moonraker.azimuth(-0.2, 0.916007137803518, -0.22925186514190146))
    }
    
    func testAstroRefractionCorrection() {
        XCTAssertEqual(0.0006664935137524817, moonraker.astroRefraction(0.4125957008354875))
    }
}
