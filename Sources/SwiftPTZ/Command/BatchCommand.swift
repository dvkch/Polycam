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
                PTZRequestSetBrightness(brightness: .init(value: b)),
                PTZRequestGetBrightness()
            ]
        }.reduce([], +)
    }
    
    func run() throws {
        guard let serialDevice = self.serialDevice ?? SerialName.firstAvailable?.rawValue else {
            fatalError("No available serial device")
        }

        do {
            let serial = try Serial(tag: "RS423", name: .init(rawValue: serialDevice))
            serial.logLevel = .error

            let camera = Camera(serial: serial)
            camera.logLevel = .debug

            for request in generateRequests() {
                print("-------------")
                camera.sendRequest(request)
                Thread.sleep(forTimeInterval: 1)
            }
            serial.stop()
        }
        catch {
            print("Error: \(error)")
        }
    }
}
