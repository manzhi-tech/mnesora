import Foundation

public struct GitAudit {
    public let directory: URL

    public enum GitError: Error {
        case commandFailed(stderr: String, code: Int32)
    }

    public init(directory: URL) {
        self.directory = directory
    }

    @discardableResult
    private func git(_ args: [String], env: [String: String] = [:]) throws -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.currentDirectoryURL = directory
        process.arguments = args
        var environment = ProcessInfo.processInfo.environment
        for (k, v) in env { environment[k] = v }
        process.environment = environment
        let stdout = Pipe()
        let stderr = Pipe()
        process.standardOutput = stdout
        process.standardError = stderr
        try process.run()
        process.waitUntilExit()
        let outData = stdout.fileHandleForReading.readDataToEndOfFile()
        let errData = stderr.fileHandleForReading.readDataToEndOfFile()
        if process.terminationStatus != 0 {
            let errStr = String(data: errData, encoding: .utf8) ?? ""
            throw GitError.commandFailed(stderr: errStr, code: process.terminationStatus)
        }
        return String(data: outData, encoding: .utf8) ?? ""
    }

    public func initIfNeeded() throws {
        let gitDir = directory.appendingPathComponent(".git")
        if FileManager.default.fileExists(atPath: gitDir.path) {
            return
        }
        try git(["init", "-b", "main"])
    }

    public func commit(message: String, author: String) throws {
        try git(["add", "-A"])
        // Check staging area for changes; skip empty commits.
        let status = try git(["status", "--porcelain"])
        if status.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return
        }
        let parts = parseAuthor(author)
        try git(
            ["commit", "-m", message],
            env: [
                "GIT_AUTHOR_NAME": parts.name,
                "GIT_AUTHOR_EMAIL": parts.email,
                "GIT_COMMITTER_NAME": parts.name,
                "GIT_COMMITTER_EMAIL": parts.email,
            ]
        )
    }

    public func log(limit: Int) throws -> [String] {
        let out = try git(["log", "--oneline", "-n", String(limit)])
        return out.split(separator: "\n").map(String.init)
    }

    private func parseAuthor(_ raw: String) -> (name: String, email: String) {
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if let openBracket = trimmed.firstIndex(of: "<"),
           let closeBracket = trimmed.lastIndex(of: ">"),
           openBracket < closeBracket {
            let name = trimmed[..<openBracket].trimmingCharacters(in: .whitespaces)
            let email = trimmed[trimmed.index(after: openBracket)..<closeBracket]
            return (String(name), String(email))
        }
        return (trimmed, "")
    }
}
