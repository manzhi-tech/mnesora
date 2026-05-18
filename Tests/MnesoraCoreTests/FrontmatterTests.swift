import XCTest
@testable import MnesoraCore

final class FrontmatterTests: XCTestCase {
    func testParseExtractsFrontmatterAndBody() throws {
        let source = """
        ---
        template: person
        name: 妻子
        preferences:
          coffee: flat white
        ---

        # 妻子

        我们怎么认识的：...
        """

        let fm = try Frontmatter.parse(source)

        XCTAssertEqual(fm.fields["template"] as? String, "person")
        XCTAssertEqual(fm.fields["name"] as? String, "妻子")
        let prefs = fm.fields["preferences"] as? [String: Any]
        XCTAssertEqual(prefs?["coffee"] as? String, "flat white")
        XCTAssertTrue(fm.body.contains("# 妻子"))
        XCTAssertTrue(fm.body.contains("我们怎么认识的"))
    }

    func testParseFailsWithNoFrontmatter() {
        let source = "# Just a heading\n\nNo frontmatter here.\n"
        XCTAssertThrowsError(try Frontmatter.parse(source))
    }
}

extension FrontmatterTests {
    func testSerializeRoundtrip() throws {
        let original = """
        ---
        template: person
        name: 妻子
        ---

        # 妻子

        Body content.
        """
        let parsed = try Frontmatter.parse(original)
        let serialized = try parsed.serialize()
        let reparsed = try Frontmatter.parse(serialized)

        XCTAssertEqual(reparsed.fields["template"] as? String, "person")
        XCTAssertEqual(reparsed.fields["name"] as? String, "妻子")
        XCTAssertTrue(reparsed.body.contains("# 妻子"))
        XCTAssertTrue(reparsed.body.contains("Body content"))
    }
}
