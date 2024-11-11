//
//  PresetCommand.swift
//  PTZ
//
//  Created by syan on 11/11/2024.
//

import Foundation
import ArgumentParser
import PTZCamera

struct PresetCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "preset", abstract: "Manage presets")
    
    @Option(name: .customLong("device"), help: "PTZ serial device name")
    var serial: String?
    
    @Option(name: .customLong("config-path"), help: "Configuration file path", transform: { URL(fileURLWithPath: $0) })
    var configPath: URL = Config.defaultURL

    @Flag(name: .customLong("list"), help: "List all presets")
    fileprivate var list: Bool = false

    @Option(name: .customLong("add"), help: "Add a new preset")
    fileprivate var add: NamedPreset?

    @Option(name: .customLong("apply"), help: "Apply a preset")
    fileprivate var apply: IndexedPreset?

    @Option(name: .customLong("remove"), help: "Remove a preset")
    fileprivate var remove: IndexedPreset?
    
    func run() throws {
        var config = Config.read(path: configPath)
        defer { config.write(to: configPath) }

        if list {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(["presets": config.presets])
            print(String(data: data, encoding: .utf8)!)
            return
        }
        
        let camera = try Result(catching: {
            try Camera(serial: .givenOrFirst(serial), logLevel: .error)
        }).mapError { ValidationError($0.localizedDescription) }.get()

        try camera.powerOnIfNeeded()

        if let add {
            let position = try camera.position()
            config.presets.append(.init(name: add.name, position: position))
            return
        }
        
        if let apply {
            guard apply.index < config.presets.count else {
                throw ValidationError("Preset \(apply.index) doesn't exist")
            }
            try camera.setPosition(config.presets[apply.index].position)
            return
        }
        
        if let remove {
            guard remove.index < config.presets.count else {
                throw ValidationError("Preset \(remove.index) doesn't exist")
            }
            config.presets.remove(at: remove.index)
            return
        }
    }
}

private extension PresetCommand {
    struct NamedPreset: ExpressibleByArgument {
        let name: String

        init?(argument: String) {
            self.name = argument
        }
    }
    
    struct IndexedPreset: ExpressibleByArgument {
        let index: Int

        init?(argument: String) {
            guard let index = Int(argument) else { return nil }
            self.index = index
        }
    }
}
