//
//  BaseCommand.swift
//
//
//  Created by syan on 11/09/2024.
//

import Foundation
import ArgumentParser
import PTZCamera

protocol BaseCommand: ParsableCommand {
    var serialDevice: String? { get }
    
    mutating func run(camera: Camera) throws(CameraError)
}

extension BaseCommand {
    mutating func run() throws(CameraError) {
        Camera.registerKnownStates()
        
        let camera = try Camera(serial: .givenOrFirst(serialDevice), logLevel: .info)
            
        do {
            try run(camera: camera)
        }
        catch {
            print("Camera error: \(error)")
        }
    }
}
