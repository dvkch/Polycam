//
//  WriteCommand.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import ArgumentParser
import Foundation
import PTZCamera
import PTZMessaging

struct WriteCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "write",
        discussion: "Available operations:\n" + availableOperations
    )

    static var availableOperations: String {
        var operations = ["boot", "pause=secs", "position=preset(...)", "preset(...)=position"]
        operations += PTZConfig.knownWriteableStates.map({ $0.cliWriteDescription })
        operations += PTZConfig.knownWriteableComboStates.map({ $0.cliWriteDescription })
        return operations.sorted().map({ "  " + $0 }).joined(separator: "\n")
    }

    @Option(name: .customLong("device"), help: "PTZ serial device name")
    var serial: String?

    @Option(name: .customLong("log"), help: "Log level")
    var logLevel: LogLevel = .error

    @Flag(name: .customLong("continue-on-failure"), help: "Continue on failure")
    var continueOnFailure: Bool = true

    typealias Operation = (String, (Camera) throws -> Void)

    @Argument(
        help: "Operations (boot, pause=secs, or any state(variant)=value)",
        transform: { try Self.parse(operation: $0) })
    var operations: [Operation] = []

    private static func parse(operation operationString: String) throws -> Operation {
        let regex = #/(?<state>[a-zA-Z0-9]+)(?:\((?<variant>[a-zA-Z0-9/]+)\))?(?:=(?<value>.*))?/#

        guard let operation = try? regex.wholeMatch(in: operationString)?.output else {
            throw ValidationError("Unrecognized syntax")
        }

        if operation.0 == "boot" {
            return ("boot", { try $0.powerOn() })
        }

        if operation.state == "pause" {
            guard let seconds = TimeInterval(operation.value.map(String.init) ?? "") else {
                throw ValidationError("Invalid parameters for pause operation")
            }
            return ("pause=\(seconds)", { _ in Thread.sleep(forTimeInterval: seconds) })
        }

        if let stateType = PTZConfig.knownWriteableComboStates.first(where: {
            $0.name.camelCased == operation.state
        }) {
            guard let state = stateType.init(valueString: operation.value.map(String.init) ?? "")
            else {
                throw ValidationError("Invalid parameters for state \"\(operation.state)\"")
            }
            return (state.description, { try $0.set(state) })
        }

        if let stateType = PTZConfig.knownWriteableStates.first(where: {
            $0.name.camelCased == operation.state
        }) {
            guard
                let state = stateType.init(
                    valueString: operation.value.map(String.init) ?? "",
                    variantString: operation.variant.map(String.init) ?? "")
            else {
                throw ValidationError("Invalid parameters for state \"\(operation.state)\"")
            }
            return (state.description, { try $0.set(state) })
        }

        throw ValidationError("Unknown operation")
    }

    mutating func run() throws {
        let camera = try Result(catching: {
            try Camera(serial: .givenOrFirst(serial), logLevel: logLevel)
        }).mapError { ValidationError($0.localizedDescription) }.get()

        try camera.powerOnIfNeeded()

        for (name, action) in operations {
            do {
                let d = Date()
                try action(camera)
                let t = Int(Date().timeIntervalSince(d) * 1000)
                print("-> \(name), \(t)ms")
            } catch {
                print("-> \(name), failed \(error)")

                if !continueOnFailure {
                    throw ExitCode.failure
                }
            }
        }
        throw ExitCode.success
    }
}
