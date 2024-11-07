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
        usage: "read brightness pan contrast calibrationHue(blue) --serial-device=/dev/serial0",
        discussion: "Available commands: " + supportedCommands.joined(separator: ", ")
    )
    
    static var supportedCommands: [String] {
        (PTZConfig.knownReadableStates.map({ $0.name.camelCased }) + PTZConfig.knownReadableCombosStates.map({ $0.name.camelCased })).sorted()
    }

    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    @Argument(help: "States")
    var states: [String] = []

    mutating func run() throws {
        Camera.registerKnownStates()

        let camera = try Result(catching: { try Camera(serial: .givenOrFirst(serialDevice), logLevel: .info) }).mapError { ValidationError($0.localizedDescription) }.get()
        camera.powerOnIfNeeded()
        camera.logLevel = .error
        
        var result = [String: (any Encodable)]()

        let regex = #/(?<name>[a-zA-Z]+)(?:\((?<variant>[a-zA-Z]+)\))?/#
        for stateString in states {
            guard let state = try? regex.wholeMatch(in: stateString)?.output else {
                throw ValidationError("Unrecognized syntax: \(stateString)")
            }

            if let stateType = PTZConfig.knownReadableCombosStates.first(where: { $0.name.camelCased == state.name }) {
                do {
                    result[stateType.name.camelCased] = try camera.get(stateType)
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
                    result[stateType.name.camelCased] = value
                }
                catch {
                    throw ValidationError(error.localizedDescription)
                }
                continue
            }

            throw ValidationError("Unknown state \"\(state.name)\"")
        }
        
        let encoder = JSONEncoder()
        let finalHash = result.mapValues({ value in
            try! encoder.encode(value)
        })
        
        let jsonString = try JSONSerialization.data(withJSONObject: finalHash, options: [.prettyPrinted, .sortedKeys])
        #warning("let's maybe make sure nothing else was printed before that?")
        print(jsonString)
        throw ExitCode.success
    }
}
