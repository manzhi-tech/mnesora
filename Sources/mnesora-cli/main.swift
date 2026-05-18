import ArgumentParser
import MnesoraCore

@main
struct MnesoraCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mnesora-cli",
        abstract: "Inspect / manipulate a mnesora card store.",
        version: Mnesora.version
    )

    func run() throws {
        print("mnesora-cli \(Mnesora.version)")
    }
}
