import XCTest
@testable import MnesoraCore

final class CardTests: XCTestCase {
    func testFromMarkdownExtractsTemplateAndBody() throws {
        let md = """
        ---
        template: person
        name: 妻子
        ---

        # 妻子

        Body.
        """
        let card = try Card.from(markdown: md, path: "people/wife.md")
        XCTAssertEqual(card.path, "people/wife.md")
        XCTAssertEqual(card.template, "person")
        let name: String? = card.field("name")
        XCTAssertEqual(name, "妻子")
        XCTAssertTrue(card.body.contains("# 妻子"))
    }

    func testMissingTemplateThrows() {
        let md = """
        ---
        name: orphan
        ---

        body
        """
        XCTAssertThrowsError(try Card.from(markdown: md, path: "orphan.md")) { error in
            XCTAssertEqual(error as? Card.CardError, .missingTemplateField)
        }
    }
}
