//
//  main.swift
//  PTZ
//
//  Created by syan on 21/05/2023.
//

import Foundation
import ArgumentParser
import PTZCamera

@main
struct PTZ: ParsableCommand {
    static var configuration: CommandConfiguration {
        var commands: [ParsableCommand.Type] = []
#if os(macOS)
        commands.append(InteractiveCommand.self)
#endif
        commands.append(ReadCommand.self)
        commands.append(WriteCommand.self)
        commands.append(PresetCommand.self)
        commands.append(AdvancedCommand.self)

        return CommandConfiguration(
            commandName: "ptz",
            abstract: "PTZ",
            version: "1.0",
            subcommands: commands
        )
    }
    
    public static func main() {
        Camera.registerKnownStates()
        self.main(nil)
    }
}
