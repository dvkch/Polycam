//
//  CamerableCommand.swift
//
//
//  Created by syan on 11/09/2024.
//

import Foundation
import ArgumentParser

protocol CamerableCommand: ParsableCommand {
    var serialDevice: String? { get }
    
    func run(camera: Camera) throws
}

extension CamerableCommand {
    func run() throws {
        guard let serialDevice = self.serialDevice ?? SerialName.firstAvailable?.rawValue else {
            fatalError("No available serial device")
        }

        let serial = try Serial(device: .init(rawValue: serialDevice), tag: "RS423", logLevel: .info)
        let camera = Camera(serial: serial, logLevel: .debug, powerOffAfterUse: false)
        
        try run(camera: camera)
    }
}
