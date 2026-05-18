import ArgumentParser
import Foundation
import MnesoraCore

struct InitCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "init",
        abstract: "Initialize an empty .mnesora store at the given directory."
    )

    @Argument(help: "Directory to initialize. Defaults to current working directory.")
    var directory: String = "."

    func run() throws {
        let root = URL(fileURLWithPath: directory)
            .appendingPathComponent(".mnesora")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)

        let audit = GitAudit(directory: root)
        try audit.initIfNeeded()

        let templatesDir = root.appendingPathComponent("templates")
        try FileManager.default.createDirectory(at: templatesDir, withIntermediateDirectories: true)
        for name in DefaultTemplates.names {
            let tpl = try DefaultTemplates.load(name)
            let header = """
            ---
            template_name: \(tpl.name)
            required_fields: \(tpl.requiredFields)
            optional_fields: \(tpl.optionalFields)
            ---

            \(tpl.bodySkeleton)
            """
            try header.write(
                to: templatesDir.appendingPathComponent("\(name).md"),
                atomically: true,
                encoding: .utf8
            )
        }

        try audit.commit(
            message: "chore: initialize mnesora store with default templates",
            author: "mnesora-cli <cli@mnesora.local>"
        )
        print("Initialized .mnesora at \(root.path)")
    }
}
