import Foundation
import Yams

public struct Template {
    public let name: String
    public let requiredFields: [String]
    public let optionalFields: [String]
    public let bodySkeleton: String

    public enum TemplateError: Error, Equatable {
        case missingMetadata(String)
        case validationFailed(missing: [String])
    }

    public init(name: String, requiredFields: [String], optionalFields: [String], bodySkeleton: String) {
        self.name = name
        self.requiredFields = requiredFields
        self.optionalFields = optionalFields
        self.bodySkeleton = bodySkeleton
    }

    public static func parse(_ source: String) throws -> Template {
        let fm = try Frontmatter.parse(source)
        guard let name = fm.fields["template_name"] as? String else {
            throw TemplateError.missingMetadata("template_name")
        }
        let required = fm.fields["required_fields"] as? [String] ?? []
        let optional = fm.fields["optional_fields"] as? [String] ?? []
        return Template(
            name: name,
            requiredFields: required,
            optionalFields: optional,
            bodySkeleton: fm.body
        )
    }

    public func validate(_ card: Card) throws {
        let missing = requiredFields.filter { card.frontmatter.fields[$0] == nil }
        if !missing.isEmpty {
            throw TemplateError.validationFailed(missing: missing)
        }
    }
}
