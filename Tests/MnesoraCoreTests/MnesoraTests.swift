import XCTest
@testable import MnesoraCore

final class MnesoraTests: XCTestCase {
    func testVersionExists() {
        XCTAssertFalse(Mnesora.version.isEmpty)
    }
}
