import Foundation
import GRDB

public struct IndexedCard: Equatable {
    public let path: String
    public let template: String
    public let frontmatterJSON: String
    public let bodyText: String
}

public struct Index {
    private let dbQueue: DatabaseQueue

    public init(path: URL) throws {
        dbQueue = try DatabaseQueue(path: path.path)
        try migrate()
    }

    private func migrate() throws {
        try dbQueue.write { db in
            try db.create(table: "cards", ifNotExists: true) { t in
                t.column("path", .text).primaryKey()
                t.column("template", .text).notNull()
                t.column("frontmatter_json", .text).notNull()
                t.column("body_text", .text).notNull()
                t.column("mtime", .datetime).notNull()
            }
            try db.create(index: "idx_cards_template", on: "cards", columns: ["template"], ifNotExists: true)
        }
    }

    public func upsert(_ card: Card) throws {
        let json = try JSONSerialization.data(withJSONObject: card.frontmatter.fields, options: [.sortedKeys])
        let jsonStr = String(data: json, encoding: .utf8) ?? "{}"
        try dbQueue.write { db in
            try db.execute(sql: """
                INSERT INTO cards (path, template, frontmatter_json, body_text, mtime)
                VALUES (?, ?, ?, ?, ?)
                ON CONFLICT(path) DO UPDATE SET
                    template = excluded.template,
                    frontmatter_json = excluded.frontmatter_json,
                    body_text = excluded.body_text,
                    mtime = excluded.mtime
            """, arguments: [card.path, card.template, jsonStr, card.body, Date()])
        }
    }

    public func search(template: String? = nil, keyword: String? = nil) throws -> [IndexedCard] {
        try dbQueue.read { db in
            var sql = "SELECT path, template, frontmatter_json, body_text FROM cards WHERE 1=1"
            var args: [DatabaseValueConvertible] = []
            if let template {
                sql += " AND template = ?"
                args.append(template)
            }
            if let keyword, !keyword.isEmpty {
                sql += " AND (body_text LIKE ? OR frontmatter_json LIKE ?)"
                args.append("%\(keyword)%")
                args.append("%\(keyword)%")
            }
            sql += " ORDER BY path"
            return try Row.fetchAll(db, sql: sql, arguments: StatementArguments(args)).map { row in
                IndexedCard(
                    path: row["path"],
                    template: row["template"],
                    frontmatterJSON: row["frontmatter_json"],
                    bodyText: row["body_text"]
                )
            }
        }
    }

    public func remove(path: String) throws {
        try dbQueue.write { db in
            try db.execute(sql: "DELETE FROM cards WHERE path = ?", arguments: [path])
        }
    }
}
