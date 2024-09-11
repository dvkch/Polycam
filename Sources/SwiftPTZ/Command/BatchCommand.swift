//
//  BatchCommand.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation
import ArgumentParser

struct BatchCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "batch")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    func run(camera: Camera) throws {
        let position = PTZRequestSetPosition(pan: .init(rawValue: 0), tilt: .init(rawValue: 0), zoom: .init(rawValue: 0))
        camera.sendRequest(position)
    }
}
