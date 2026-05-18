import ArgumentParser
import Foundation
import MnesoraCore

struct CardShowCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "show",
        abstract: "Print a card's contents."
    )

    @Option(help: "Path to the .mnesora directory.")
    var store: String = ".mnesora"

    @Argument(help: "Relative path of the card, e.g. people/wife.md")
    var path: String

    func run() throws {
        let root = URL(fileURLWithPath: store)
        let cs = CardStore(root: root)
        let card = try cs.read(path)
        print("template: \(card.template)")
        print("path: \(card.path)")
        print("---")
        print(try card.serialize())
    }
}
