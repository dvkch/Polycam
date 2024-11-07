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
import PTZCommon

struct ReadCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(
        commandName: "read",
        usage: "read brightness pan contrast calibrationHue(blue) --device=/dev/serial0",
        discussion: "Available commands: " + supportedCommands.joined(separator: ", ")
    )
    
    static var supportedCommands: [String] {
        (PTZConfig.knownReadableStates.map({ $0.name.camelCased }) + PTZConfig.knownReadableCombosStates.map({ $0.name.camelCased })).sorted()
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
        
        var result = [String: Any]()
        result["device"] = serial.rawValue

        let regex = #/(?<name>[a-zA-Z0-9]+)(?:\((?<variant>[a-zA-Z0-9]+)\))?/#
        for stateString in states {
            guard let state = try? regex.wholeMatch(in: stateString)?.output else {
                throw ValidationError("Unrecognized syntax: \(stateString)")
            }

            if let stateType = PTZConfig.knownReadableCombosStates.first(where: { $0.name.camelCased == state.name }) {
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
                continue
            }

            if let stateType = PTZConfig.knownReadableStates.first(where: { $0.name.camelCased == state.name }) {
                do {
                    guard let value = try camera.get(stateType, forCli: state.variant.map(String.init) ?? "") else {
                        throw ValidationError("Invalid parameters for state \"\(state.name)\"")
                    }
                    result[stateType.name.camelCased] = [
                        "value": value.toJSON,
                        "name": value.description
                    ]
                }
                catch {
                    throw ValidationError(error.localizedDescription)
                }
                continue
            }

            throw ValidationError("Unknown state \"\(state.name)\"")
        }
        
        print(result)
        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        #warning("let's maybe make sure nothing else was printed before that?")
        print(jsonString)
        throw ExitCode.success
    }
}
