import XCTest
@testable import MnesoraCore

final class IndexTests: XCTestCase {
    var dbPath: URL!

    override func setUp() {
        super.setUp()
        dbPath = FileManager.default.temporaryDirectory
            .appendingPathComponent("mnesora-idx-\(UUID().uuidString).sqlite")
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: dbPath)
        super.tearDown()
    }

    func testUpsertAndQueryByTemplate() throws {
        let index = try Index(path: dbPath)
        let card = Card(
            path: "people/wife.md",
            template: "person",
            frontmatter: Frontmatter(
                fields: ["template": "person", "name": "妻子", "relation": "spouse"],
                body: "# 妻子\n\nBody."
            )
        )
        try index.upsert(card)
        let hits = try index.search(template: "person")
        XCTAssertEqual(hits.count, 1)
        XCTAssertEqual(hits.first?.path, "people/wife.md")
    }

    func testKeywordSearchInBody() throws {
        let index = try Index(path: dbPath)
        let card = Card(
            path: "stances/typescript.md",
            template: "stance",
            frontmatter: Frontmatter(
                fields: ["template": "stance", "topic": "typescript", "position": "default for new web"],
                body: "I prefer TypeScript with strict mode enabled."
            )
        )
        try index.upsert(card)
        let hits = try index.search(keyword: "strict")
        XCTAssertEqual(hits.count, 1)
    }

    func testUpsertReplacesExisting() throws {
        let index = try Index(path: dbPath)
        let card1 = Card(
            path: "p.md",
            template: "preference",
            frontmatter: Frontmatter(fields: ["template": "preference", "domain": "tea", "value": "puer"], body: "")
        )
        try index.upsert(card1)
        let card2 = Card(
            path: "p.md",
            template: "preference",
            frontmatter: Frontmatter(fields: ["template": "preference", "domain": "tea", "value": "oolong"], body: "")
        )
        try index.upsert(card2)
        let hits = try index.search(template: "preference")
        XCTAssertEqual(hits.count, 1)
        XCTAssertTrue(hits[0].frontmatterJSON.contains("oolong"))
    }

    func testRemove() throws {
        let index = try Index(path: dbPath)
        let card = Card(
            path: "p.md",
            template: "preference",
            frontmatter: Frontmatter(fields: ["template": "preference", "domain": "tea", "value": "puer"], body: "")
        )
        try index.upsert(card)
        try index.remove(path: "p.md")
        XCTAssertEqual(try index.search(template: "preference").count, 0)
    }
}
