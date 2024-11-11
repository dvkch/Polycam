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
        discussion: "Available operations:\n" + availableOperations
    )
    
    static var availableOperations: String {
        var operations = ["all", "moving"]
        operations += PTZConfig.knownReadableStates.map({ $0.cliReadDescription })
        operations += PTZConfig.knownReadableCombosStates.map({ $0.cliReadDescription })
        return operations.sorted().map({ "  " + $0 }).joined(separator: "\n")
    }
    
    @Option(name: .customLong("device"), help: "PTZ serial device name")
    var serial: String?
    
    @Option(name: .customLong("log"), help: "Log level")
    var logLevel: LogLevel = .error
    
    typealias Operation = (Camera, inout [String: JSONValue]) throws -> ()
    
    @Argument(help: "States, e.g. calibrationHue(cyan)", transform: { try Self.parseOperation($0) })
    var states: [[Operation]] = []
    
    private static func parseOperation(_ operationString: String) throws -> [Operation] {
        let regex = #/(?<name>[a-zA-Z0-9]+)(?:\((?<variant>[a-zA-Z0-9/]+)\))?/#
        guard let state = try? regex.wholeMatch(in: operationString)?.output else {
            throw ValidationError("Unrecognized syntax")
        }
        
        if state.name == "all" {
            var operations = [Operation]()
            for state in PTZConfig.knownReadableCombosStates {
                operations.append({ try Self.readState(state, camera: $0, result: &$1) })
            }
            for state in PTZConfig.knownReadableStates {
                for variant in state.variants {
                    operations.append({ try Self.readState(state, for: variant.description, camera: $0, result: &$1) })
                }
            }
            return operations
        }
        
        if state.name == "moving" {
            return [{
                let position1 = try $0.position()
                Thread.sleep(forTimeInterval: 0.05)
                let position2 = try $0.position()
                let moving = PTZBool(rawValue: position1 != position2)
                $1["moving"] = [
                    "value": moving.rawValue,
                    "name": moving.description
                ]
            }]
        }
        
        if let stateType = PTZConfig.knownReadableCombosStates.first(where: { $0.name.camelCased == state.name }) {
            return [{ try Self.readState(stateType, camera: $0, result: &$1) }]
        }
        
        if let stateType = PTZConfig.knownReadableStates.first(where: { $0.name.camelCased == state.name }) {
            return [{ try Self.readState(stateType, for: state.variant.map(String.init) ?? "", camera: $0, result: &$1) }]
        }
        
        throw ValidationError("Unknown state")
    }
    
    mutating func run() throws {
        let (serial, camera) = try Result(catching: {
            let serial = try SerialName.givenOrFirst(self.serial)
            let camera = try Camera(serial: serial, logLevel: logLevel)
            return (serial, camera)
        }).mapError { ValidationError($0.localizedDescription) }.get()
        
        try camera.powerOnIfNeeded()
        
        var result = [String: JSONValue]()
        result["device"] = serial.rawValue
        
        for operations in states {
            for operation in operations {
                try operation(camera, &result)
            }
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: result, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print(jsonString)
        
        throw ExitCode.success
    }
}

private extension ReadCommand {
    static func readState<T: PTZReadableCombo>(_ stateType: T.Type, camera: Camera, result: inout [String: JSONValue]) throws {
        do {
            let key = stateType.name.camelCased
            let value = try camera.get(stateType)
            result[key] = [
                "value": value.toJSON,
                "name": value.description
            ]
        }
        catch {
            throw ValidationError(error.localizedDescription)
        }
    }
    
    static func readState<T: PTZReadable>(_ stateType: T.Type, for variant: String, camera: Camera, result: inout [String: JSONValue]) throws {
        do {
            guard let value = try camera.get(stateType, forCli: variant) else {
                throw ValidationError("Invalid parameters for state \"\(stateType.name)\"")
            }
            
            let key = stateType.name.camelCased
            if variant == "" {
                result[key] = [
                    "value": value.toJSON,
                    "name": value.description
                ]
            }
            else {
                if result[key] == nil {
                    result[key] = [String: any JSONValue]()
                }
                var currentValue = result[key]! as! [String: any JSONValue]
                currentValue[variant] = [
                    "value": value.toJSON,
                    "name": value.description
                ]
                result[key] = currentValue
            }
        }
        catch {
            throw ValidationError(error.localizedDescription)
        }
    }
}
