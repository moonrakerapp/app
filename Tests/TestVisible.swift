@testable import Moonraker
import XCTest

final class TestVisible: XCTestCase {
    private var moonraker: Moonraker!
    
    override func setUp() {
        moonraker = .init()
    }
    
    func testVisible() {
        XCTAssertEqual(0.5490432602177777, moonraker.visible(1300000000))
    }
    
    func testDays() {
        XCTAssertEqual(4088.7962962961756, moonraker.days(1300000000))
    }
    
    func testSunDeclination() {
        XCTAssertEqual(0.09136648771862077, moonraker.sunCoords(5000).0)
    }
    
    func testSunRightAscension() {
        XCTAssertEqual(2.928664200072675, moonraker.sunCoords(5000).1)
    }
    
    func testSolarMeanAnomaly() {
        XCTAssertEqual(92.24990993958214, moonraker.solarMeanAnomaly(5000))
    }
    
    func testEclipticLongitude() {
        XCTAssertEqual(97.15794246793237, moonraker.eclipticLongitude(92.24990993958214))
    }
    
    func testDeclination() {
        XCTAssertEqual(0.09136648771862077, moonraker.declination(0, 97.15794246793237))
    }
    
    func testRightAscension() {
        XCTAssertEqual(2.928664200072675, moonraker.rightAscension(0, 97.15794246793237))
    }
    
    
}
