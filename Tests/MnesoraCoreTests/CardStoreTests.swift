import XCTest
@testable import MnesoraCore

final class CardStoreTests: XCTestCase {
    var tmpDir: URL!

    override func setUp() {
        super.setUp()
        tmpDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("mnesora-test-\(UUID().uuidString)")
        try? FileManager.default.createDirectory(at: tmpDir, withIntermediateDirectories: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: tmpDir)
        super.tearDown()
    }

    func testCreateThenRead() throws {
        let store = CardStore(root: tmpDir)
        let card = Card(
            path: "people/wife.md",
            template: "person",
            frontmatter: Frontmatter(
                fields: ["template": "person", "name": "妻子", "relation": "spouse"],
                body: "# 妻子\n\nBody.\n"
            )
        )
        try store.create(card)

        let loaded = try store.read("people/wife.md")
        XCTAssertEqual(loaded.template, "person")
        let name: String? = loaded.field("name")
        XCTAssertEqual(name, "妻子")
    }

    func testCreateRejectsExistingPath() throws {
        let store = CardStore(root: tmpDir)
        let card = Card(
            path: "x.md",
            template: "preference",
            frontmatter: Frontmatter(
                fields: ["template": "preference", "domain": "coffee", "value": "flat white"],
                body: "body"
            )
        )
        try store.create(card)
        XCTAssertThrowsError(try store.create(card)) { error in
            XCTAssertEqual(error as? CardStore.CardStoreError, .alreadyExists("x.md"))
        }
    }

    func testUpdateOverwrites() throws {
        let store = CardStore(root: tmpDir)
        var card = Card(
            path: "p.md",
            template: "preference",
            frontmatter: Frontmatter(
                fields: ["template": "preference", "domain": "tea", "value": "puer"],
                body: "body"
            )
        )
        try store.create(card)
        card.setField("value", value: "oolong")
        try store.update(card)
        let loaded = try store.read("p.md")
        let value: String? = loaded.field("value")
        XCTAssertEqual(value, "oolong")
    }

    func testDeleteRemoves() throws {
        let store = CardStore(root: tmpDir)
        let card = Card(
            path: "p.md",
            template: "preference",
            frontmatter: Frontmatter(
                fields: ["template": "preference", "domain": "tea", "value": "puer"],
                body: "body"
            )
        )
        try store.create(card)
        try store.delete("p.md")
        XCTAssertThrowsError(try store.read("p.md")) { error in
            XCTAssertEqual(error as? CardStore.CardStoreError, .notFound("p.md"))
        }
    }

    func testRejectsPathTraversal() {
        let store = CardStore(root: tmpDir)
        let badCard = Card(
            path: "../escape.md",
            template: "preference",
            frontmatter: Frontmatter(fields: ["template": "preference", "domain": "x", "value": "y"], body: "")
        )
        XCTAssertThrowsError(try store.create(badCard)) { error in
            XCTAssertEqual(error as? CardStore.CardStoreError, .pathTraversal)
        }
    }
}
