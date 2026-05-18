import ArgumentParser
import MnesoraCore

@main
struct MnesoraCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mnesora-cli",
        abstract: "Inspect / manipulate a mnesora card store.",
        version: Mnesora.version,
        subcommands: [
            InitCommand.self,
            CardListCommand.self,
            CardShowCommand.self,
        ]
    )
}
