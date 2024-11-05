//
//  main.swift
//  SwiftPTZ
//
//  Created by syan on 21/05/2023.
//

import Foundation
import ArgumentParser

@main
struct SwiftPTZ: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "SwiftPTZ",
        version: "1.0",
        subcommands: [BatchCommand.self, FuzzerCommand.self, TesterCommand.self, BenchmarkCommand.self, InteractiveCommand.self],
        defaultSubcommand: InteractiveCommand.self
    )
}

#warning("split in multiple modules, one for serial communication and JCCP protocol basics, one for the camera, and one for CLI")
