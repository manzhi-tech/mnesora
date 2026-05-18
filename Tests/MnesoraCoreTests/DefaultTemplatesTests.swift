import XCTest
@testable import MnesoraCore

final class DefaultTemplatesTests: XCTestCase {
    func testAllSixTemplatesLoad() throws {
        let all = try DefaultTemplates.loadAll()
        XCTAssertEqual(all.count, 6)
        XCTAssertEqual(Set(all.map(\.name)), [
            "identity", "person", "project", "stance", "decision", "preference",
        ])
    }

    func testPersonTemplateHasRequiredFields() throws {
        let person = try DefaultTemplates.load("person")
        XCTAssertEqual(person.requiredFields, ["name", "relation"])
    }
}
