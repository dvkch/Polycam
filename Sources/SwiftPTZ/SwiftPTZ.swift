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
        version: "1.0"
    )

    func run() throws {
        print("Hello from PTZ")
    }
}
