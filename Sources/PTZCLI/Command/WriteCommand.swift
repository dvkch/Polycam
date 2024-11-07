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
import PTZCommon

struct WriteCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "write",
        usage: "write brightness=10 pan=500 contrast=3 moveTilt(up)=50 --device=/dev/serial0",
        discussion: "Available commands: " + supportedCommands.joined(separator: ", ")
    )
    
    static var supportedCommands: [String] {
        ["boot"] + (PTZConfig.knownWriteableStates.map({ $0.name.camelCased }) + PTZConfig.knownWriteableComboStates.map({ $0.name.camelCased })).sorted()
    }
    
    @Option(name: .customLong("device"), help: "PTZ serial device name")
    var serial: String?
    
    @Option(name: .customLong("log"), help: "Log level")
    var logLevel: LogLevel = .error

    @Argument(help: "Operations")
    var operations: [String] = []

    mutating func run() throws {
        Camera.registerKnownStates()

        var actions: [(String, (Camera) throws -> ())] = []

        let regex = #/(?<state>[a-zA-Z0-9]+)(?:\((?<variant>[a-zA-Z0-9]+)\))?(?:=(?<value>.*))?/#
        for operationString in operations {
            guard let operation = try? regex.wholeMatch(in: operationString)?.output else {
                throw ValidationError("Unrecognized syntax: \(operationString)")
            }

            if operation.0 == "boot" {
                actions.append(("boot", { $0.powerOn() }))
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
        camera.powerOnIfNeeded()
        
        for (name, action) in actions {
            do {
                try action(camera)
            }
            catch {
                print("Error running \(name): \(error)")
                throw ExitCode.failure
            }
        }
        throw ExitCode.success
    }
}
