//
//  AdvancedCommand.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import ArgumentParser

struct AdvancedCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "advanced", subcommands: [
        BenchmarkCommand.self, FuzzerCommand.self, TesterCommand.self
    ])
}
