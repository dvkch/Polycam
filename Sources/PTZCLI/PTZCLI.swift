//
//  main.swift
//  SwiftPTZ
//
//  Created by syan on 21/05/2023.
//

import Foundation
import ArgumentParser

@main
struct PTZCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "PTZ",
        version: "1.0",
        subcommands: [FuzzerCommand.self, TesterCommand.self, BenchmarkCommand.self, InteractiveCommand.self],
        defaultSubcommand: InteractiveCommand.self
    )
}
