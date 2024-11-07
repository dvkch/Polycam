//
//  main.swift
//  PTZ
//
//  Created by syan on 21/05/2023.
//

import Foundation
import ArgumentParser

#warning("Confirm fuzzer still works")
#warning("set up all mode conditions rescues for all requests")
#warning("Add comments to all the states, explaning how they were found and how they work")
#warning("Cleanup extensions")

#warning("Rewrite PTZValue properly, split protocol definition in their own files?")

#warning("use a specific struct type for Registers, allowing them to handle variants (using a case iterable enum and an offset)")
#warning("make it work on linux")


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
