import Foundation

public enum DefaultTemplates {
    public static let names: [String] = [
        "identity", "person", "project", "stance", "decision", "preference",
    ]

    public enum LoadError: Error, Equatable {
        case notFound(String)
    }

    public static func load(_ name: String) throws -> Template {
        guard let url = Bundle.module.url(
            forResource: name,
            withExtension: "md",
            subdirectory: "Templates"
        ) else {
            throw LoadError.notFound(name)
        }
        let source = try String(contentsOf: url, encoding: .utf8)
        return try Template.parse(source)
    }

    public static func loadAll() throws -> [Template] {
        try names.map { try load($0) }
    }
}
