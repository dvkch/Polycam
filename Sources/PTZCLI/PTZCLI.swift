//
//  main.swift
//  PTZ
//
//  Created by syan on 21/05/2023.
//

import Foundation
import ArgumentParser

@main
struct PTZCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ptz",
        abstract: "PTZ",
        version: "1.0",
        subcommands: [
            AdvancedCommand.self,
            BenchmarkCommand.self,
            InteractiveCommand.self,
            ReadCommand.self,
            WriteCommand.self
        ]
    )
}
