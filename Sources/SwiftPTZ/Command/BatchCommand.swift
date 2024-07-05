//
//  BatchCommand.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation
import ArgumentParser

struct BatchCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "batch")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    private func generateRequests() -> [PTZRequest] {
        return (0..<20).map { b in
            [
                PTZRequestSetPosition(
                    pan: .init(rawValue:  (PTZPositionPan.minValue...PTZPositionPan.maxValue).randomElement()!),
                    tilt: .init(rawValue: (PTZPositionTilt.minValue...PTZPositionTilt.maxValue).randomElement()!),
                    zoom: .init(rawValue: (PTZPositionZoom.minValue...PTZPositionZoom.maxValue).randomElement()!)
                ),
                PTZRequestGetPosition()
            ]
        }.reduce([], +)
    }
    
    func run() throws {
        guard let serialDevice = self.serialDevice ?? SerialName.firstAvailable?.rawValue else {
            fatalError("No available serial device")
        }

        do {
            let serial = try Serial(tag: "RS423", name: .init(rawValue: serialDevice))
            serial.logLevel = .info

            let camera = Camera(serial: serial)
            camera.logLevel = .info

            for request in generateRequests() {
                print("-------------")
                camera.sendRequest(request)
                Thread.sleep(forTimeInterval: 0.5)
            }
            camera.stop()
        }
        catch {
            print("Error: \(error)")
        }
    }
}
