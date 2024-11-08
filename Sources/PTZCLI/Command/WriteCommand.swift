//
//  WriteCommand.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import ArgumentParser
import PTZCamera
import PTZMessaging

#warning("subcommand to list all available commands, variants and values cases or min/max")
struct WriteCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "write",
        usage: "write boot brightness=10 contrast=3  pan=500 moveTilt(up)=50 pause=2.5 moveTilt(stop)=0 --device=/dev/serial0",
        discussion: "Available commands: " + supportedCommands.joined(separator: ", ")
    )
    
    static var supportedCommands: [String] {
        ["boot", "pause=secs"] + (PTZConfig.knownWriteableStates.map({ $0.name.camelCased }) + PTZConfig.knownWriteableComboStates.map({ $0.name.camelCased })).sorted()
    }
    
    @Option(name: .customLong("device"), help: "PTZ serial device name")
    var serial: String?
    
    @Option(name: .customLong("log"), help: "Log level")
    var logLevel: LogLevel = .error
    
    @Option(name: .customLong("continue"), help: "Continue on failure")
    var continueOnFailure: Bool = true

    @Argument(help: "Operations")
    var operations: [String] = []

    mutating func run() throws {
        Camera.registerKnownStates()

        var actions: [(String, (Camera) throws -> ())] = []

        let regex = #/(?<state>[a-zA-Z0-9]+)(?:\((?<variant>[a-zA-Z0-9/]+)\))?(?:=(?<value>.*))?/#
        for operationString in operations {
            guard let operation = try? regex.wholeMatch(in: operationString)?.output else {
                throw ValidationError("Unrecognized syntax: \(operationString)")
            }

            if operation.0 == "boot" {
                actions.append(("boot", { try $0.powerOn() }))
                continue
            }
            
            if operation.state == "pause" {
                guard let seconds = TimeInterval(operation.value.map(String.init) ?? "") else {
                    throw ValidationError("Invalid parameters for state \"\(operation.state)\"")
                }
                actions.append(("pause(\(seconds))", { _ in Thread.sleep(forTimeInterval: seconds) }))
                continue
            }
            
            if let stateType = PTZConfig.knownWriteableComboStates.first(where: { $0.name.camelCased == operation.state }) {
                guard let state = stateType.init(valueString: operation.value.map(String.init) ?? "") else {
                    throw ValidationError("Invalid parameters for state \"\(operation.state)\"")
                }
                actions.append((state.description, { try $0.set(state) }))
                continue
            }

            if let stateType = PTZConfig.knownWriteableStates.first(where: { $0.name.camelCased == operation.state }) {
                guard let state = stateType.init(valueString: operation.value.map(String.init) ?? "", variantString: operation.variant.map(String.init) ?? "") else {
                    throw ValidationError("Invalid parameters for state \"\(operation.state)\"")
                }
                actions.append((state.description, { try $0.set(state) }))
                continue
            }

            throw ValidationError("Unknown state \"\(operation.state)\"")
        }
        
        let camera = try Result(catching: {
            try Camera(serial: .givenOrFirst(serial), logLevel: logLevel)
        }).mapError { ValidationError($0.localizedDescription) }.get()

        try camera.powerOnIfNeeded()

        for (name, action) in actions {
            do {
                print("-> \(name)", terminator: "")

                let d = Date()
                try action(camera)
                let t = Int(Date().timeIntervalSince(d) * 1000)
                print(", \(t)ms")
            }
            catch {
                print(", failed \(error)")
                
                if !continueOnFailure {
                    throw ExitCode.failure
                }
            }
        }
        throw ExitCode.success
    }
}
