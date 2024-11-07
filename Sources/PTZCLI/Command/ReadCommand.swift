//
//  ReadCommand.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import ArgumentParser
import PTZCamera
import PTZMessaging

struct ReadCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "read",
        usage: "read brightness pan contrast calibrationHue(blue) --device=/dev/serial0",
        discussion: "Available commands: " + supportedCommands.joined(separator: ", ")
    )
    
    static var supportedCommands: [String] {
        ["all"] + (PTZConfig.knownReadableStates.map({ $0.name.camelCased }) + PTZConfig.knownReadableCombosStates.map({ $0.name.camelCased })).sorted()
    }

    @Option(name: .customLong("device"), help: "PTZ serial device name")
    var serial: String?
    
    @Option(name: .customLong("log"), help: "Log level")
    var logLevel: LogLevel = .error
    
    @Argument(help: "States")
    var states: [String] = []

    mutating func run() throws {
        Camera.registerKnownStates()

        let (serial, camera) = try Result(catching: {
            let serial = try SerialName.givenOrFirst(self.serial)
            let camera = try Camera(serial: serial, logLevel: logLevel)
            return (serial, camera)
        }).mapError { ValidationError($0.localizedDescription) }.get()

        camera.powerOnIfNeeded()
        
        var result = [String: JSONValue]()
        result["device"] = serial.rawValue

        let regex = #/(?<name>[a-zA-Z0-9]+)(?:\((?<variant>[a-zA-Z0-9]+)\))?/#
        for stateString in states {
            guard let state = try? regex.wholeMatch(in: stateString)?.output else {
                throw ValidationError("Unrecognized syntax: \(stateString)")
            }
            
            if state.name == "all" {
                for state in PTZConfig.knownReadableCombosStates {
                    try readState(state, camera: camera, result: &result)
                }
                for state in PTZConfig.knownReadableStates {
                    for variant in state.variants {
                        try readState(state, for: variant.description, camera: camera, result: &result)
                    }
                }
                continue
            }

            if let stateType = PTZConfig.knownReadableCombosStates.first(where: { $0.name.camelCased == state.name }) {
                try readState(stateType, camera: camera, result: &result)
                continue
            }

            if let stateType = PTZConfig.knownReadableStates.first(where: { $0.name.camelCased == state.name }) {
                try readState(stateType, for: state.variant.map(String.init) ?? "", camera: camera, result: &result)
                continue
            }

            throw ValidationError("Unknown state \"\(state.name)\"")
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)

        throw ExitCode.success
    }
    
    private func readState<T: PTZReadableCombo>(_ stateType: T.Type, camera: Camera, result: inout [String: JSONValue]) throws {
        do {
            let value = try camera.get(stateType)
            result[stateType.name.camelCased] = [
                "value": value.toJSON,
                "name": value.description
            ]
        }
        catch {
            throw ValidationError(error.localizedDescription)
        }
    }
    
    private func readState<T: PTZReadable>(_ stateType: T.Type, for variant: String, camera: Camera, result: inout [String: JSONValue]) throws {
        do {
            guard let value = try camera.get(stateType, forCli: variant) else {
                throw ValidationError("Invalid parameters for state \"\(stateType.name)\"")
            }
            var name = stateType.name.camelCased
            if variant != "" {
                name += "(\(variant))"
            }
            result[name] = [
                "value": value.toJSON,
                "name": value.description
            ]
        }
        catch {
            throw ValidationError(error.localizedDescription)
        }
    }
}
