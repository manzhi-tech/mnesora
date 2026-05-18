import ArgumentParser
import Foundation
import MnesoraCore

struct CardListCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "list",
        abstract: "List all card paths in the store."
    )

    @Option(help: "Path to the .mnesora directory.")
    var store: String = ".mnesora"

    func run() throws {
        let root = URL(fileURLWithPath: store)
        let cs = CardStore(root: root)
        for path in try cs.list() {
            print(path)
        }
    }
}
