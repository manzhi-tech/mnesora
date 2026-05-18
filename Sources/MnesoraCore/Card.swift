import Foundation

public struct Card {
    public let path: String          // relative to store root, e.g. "people/wife.md"
    public let template: String      // "person", "project", ...
    public var frontmatter: Frontmatter

    public enum CardError: Error, Equatable {
        case missingTemplateField
    }

    public var body: String { frontmatter.body }

    public init(path: String, template: String, frontmatter: Frontmatter) {
        self.path = path
        self.template = template
        self.frontmatter = frontmatter
    }

    public static func from(markdown: String, path: String) throws -> Card {
        let fm = try Frontmatter.parse(markdown)
        guard let template = fm.fields["template"] as? String else {
            throw CardError.missingTemplateField
        }
        return Card(path: path, template: template, frontmatter: fm)
    }

    public func field<T>(_ key: String) -> T? {
        frontmatter.fields[key] as? T
    }

    public mutating func setField(_ key: String, value: Any) {
        frontmatter.fields[key] = value
    }

    public mutating func removeField(_ key: String) {
        frontmatter.fields.removeValue(forKey: key)
    }

    public func serialize() throws -> String {
        try frontmatter.serialize()
    }
}
