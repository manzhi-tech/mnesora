import Foundation

public struct CardStore {
    public let root: URL

    public enum CardStoreError: Error, Equatable {
        case pathTraversal
        case alreadyExists(String)
        case notFound(String)
    }

    public init(root: URL) {
        // Normalize symlinks once so list() path-stripping works on macOS
        // where /var -> /private/var and /tmp -> /private/tmp.
        self.root = root.resolvingSymlinksInPath()
    }

    private func resolved(_ path: String) throws -> URL {
        if path.contains("..") || path.hasPrefix("/") {
            throw CardStoreError.pathTraversal
        }
        return root.appendingPathComponent(path)
    }

    public func create(_ card: Card) throws {
        let url = try resolved(card.path)
        let fm = FileManager.default
        try fm.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        if fm.fileExists(atPath: url.path) {
            throw CardStoreError.alreadyExists(card.path)
        }
        let text = try card.serialize()
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    public func read(_ path: String) throws -> Card {
        let url = try resolved(path)
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else {
            throw CardStoreError.notFound(path)
        }
        let text = try String(contentsOf: url, encoding: .utf8)
        return try Card.from(markdown: text, path: path)
    }

    public func update(_ card: Card) throws {
        let url = try resolved(card.path)
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else {
            throw CardStoreError.notFound(card.path)
        }
        let text = try card.serialize()
        try text.write(to: url, atomically: true, encoding: .utf8)
    }

    public func delete(_ path: String) throws {
        let url = try resolved(path)
        let fm = FileManager.default
        guard fm.fileExists(atPath: url.path) else {
            throw CardStoreError.notFound(path)
        }
        try fm.removeItem(at: url)
    }

    public func list() throws -> [String] {
        let fm = FileManager.default
        guard let enumerator = fm.enumerator(at: root, includingPropertiesForKeys: nil) else {
            return []
        }
        var out: [String] = []
        for case let fileURL as URL in enumerator where fileURL.pathExtension == "md" {
            let rel = fileURL.path.replacingOccurrences(of: root.path + "/", with: "")
            out.append(rel)
        }
        return out
    }
}
