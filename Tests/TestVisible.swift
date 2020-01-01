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
}
