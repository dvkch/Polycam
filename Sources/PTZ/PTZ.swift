//
//  main.swift
//  PTZ
//
//  Created by syan on 21/05/2023.
//

import Foundation
import ArgumentParser

@main
struct PTZ: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "ptz",
        abstract: "PTZ",
        version: "1.0",
        subcommands: [
            InteractiveCommand.self,
            ReadCommand.self,
            WriteCommand.self,
            AdvancedCommand.self,
        ]
    )
    
    public static func main() {
        self.main(nil)
    }
}
