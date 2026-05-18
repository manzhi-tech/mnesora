import XCTest
@testable import MnesoraCore

final class TemplateTests: XCTestCase {
    func testParseExtractsNameAndFields() throws {
        let md = """
        ---
        template_name: person
        required_fields: [name, relation]
        optional_fields: [preferences, important_dates, do_not_suggest]
        ---

        # {{name}}

        ## 我们怎么认识的

        ## AI 观察
        """
        let tpl = try Template.parse(md)
        XCTAssertEqual(tpl.name, "person")
        XCTAssertEqual(tpl.requiredFields, ["name", "relation"])
        XCTAssertEqual(tpl.optionalFields, ["preferences", "important_dates", "do_not_suggest"])
        XCTAssertTrue(tpl.bodySkeleton.contains("AI 观察"))
    }

    func testValidateAcceptsCardWithRequiredFields() throws {
        let tpl = Template(
            name: "person",
            requiredFields: ["name", "relation"],
            optionalFields: [],
            bodySkeleton: ""
        )
        let card = Card(
            path: "people/wife.md",
            template: "person",
            frontmatter: Frontmatter(
                fields: ["template": "person", "name": "妻子", "relation": "spouse"],
                body: ""
            )
        )
        XCTAssertNoThrow(try tpl.validate(card))
    }

    func testValidateRejectsCardMissingRequiredField() throws {
        let tpl = Template(
            name: "person",
            requiredFields: ["name", "relation"],
            optionalFields: [],
            bodySkeleton: ""
        )
        let card = Card(
            path: "people/wife.md",
            template: "person",
            frontmatter: Frontmatter(
                fields: ["template": "person", "name": "妻子"],  // missing "relation"
                body: ""
            )
        )
        XCTAssertThrowsError(try tpl.validate(card)) { error in
            guard case Template.TemplateError.validationFailed(let missing) = error else {
                XCTFail("expected validationFailed")
                return
            }
            XCTAssertEqual(missing, ["relation"])
        }
    }
}
