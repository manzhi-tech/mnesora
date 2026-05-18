import Foundation
import Yams

public struct Frontmatter {
    public var fields: [String: Any]
    public var body: String

    public enum ParseError: Error, Equatable {
        case missingOpeningDelimiter
        case missingClosingDelimiter
        case invalidYAML(String)
    }

    public init(fields: [String: Any] = [:], body: String = "") {
        self.fields = fields
        self.body = body
    }

    public static func parse(_ source: String) throws -> Frontmatter {
        let delimiter = "---\n"
        guard source.hasPrefix(delimiter) else {
            throw ParseError.missingOpeningDelimiter
        }
        let afterOpen = source.dropFirst(delimiter.count)
        guard let closeRange = afterOpen.range(of: "\n---\n") else {
            throw ParseError.missingClosingDelimiter
        }
        let yamlSlice = afterOpen[..<closeRange.lowerBound]
        let bodySlice = afterOpen[closeRange.upperBound...]

        do {
            let parsed = try Yams.load(yaml: String(yamlSlice)) as? [String: Any] ?? [:]
            return Frontmatter(fields: parsed, body: String(bodySlice))
        } catch {
            throw ParseError.invalidYAML(String(describing: error))
        }
    }

    public func serialize() throws -> String {
        let yaml = try Yams.dump(object: fields)
        return "---\n\(yaml)---\n\n\(body)"
    }
}
