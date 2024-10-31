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
    
    mutating func run(camera: Camera) throws(CameraError)
}

extension CamerableCommand {
    mutating func run() throws(CameraError) {
        guard let serialDevice = self.serialDevice ?? Serial.Name.firstAvailable?.rawValue else {
            fatalError("No available serial device")
        }
        
        let camera = try Camera(serial: .init(rawValue: serialDevice), logLevel: .info, powerOffAfterUse: false)
            
        do {
            try run(camera: camera)
        }
        catch {
            print("Camera error: \(error)")
        }
    }
}
