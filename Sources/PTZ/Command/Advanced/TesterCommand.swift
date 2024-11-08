//
//  TesterCommand.swift
//  PTZ
//
//  Created by syan on 10/09/2024.
//

import Foundation
import ArgumentParser
import PTZCamera
import PTZMessaging

struct TesterCommand: ParsableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "tester")
    
    @Option(name: .customLong("device"), help: "PTZ serial device name")
    var serial: String?
    
    @Option(name: .customLong("log"), help: "Log level")
    var logLevel: LogLevel = .error

    mutating func run() throws(CameraError) {
        Camera.registerKnownStates()

        let camera = try Camera(serial: .givenOrFirst(serial), logLevel: logLevel)
        try camera.powerOn()

        try! testRandomThingy(camera: camera)
    }
    
    private func testRandomThingy(camera: Camera) throws {
        camera.logLevel = .error

        let startDate = Date()
        var previousBytes: Bytes = []

        var lastRoundWasUnequal5 = false
        var lastDateUnequal = Date()
        
        print("|   tStart  |     t≠    | ≠ | reply hex                                          | reply bin")
        print("|-----------|-----------|---|----------------------------------------------------|-------------------------|")
        
        while Date().timeIntervalSince(startDate) < 3600 {
            let t = Date()

            let current = camera.send(.unknown((0x01, 0x44), arg: nil)).bytes
            defer { previousBytes = current }

            if current == previousBytes { continue }
            
            let currentIsUnequal = Set([6, 8, 9, 10, 15].map({ current[$0] })).count > 1
            if !currentIsUnequal && lastRoundWasUnequal5 { lastDateUnequal = Date() }
            defer { lastRoundWasUnequal5 = currentIsUnequal }
            
            let tS      = String(format: "%5.03lf", t.timeIntervalSince(startDate)).leftPad(count: 8, padding: " ")
            let tSince  = String(format: "%5.03lf", t.timeIntervalSince(lastDateUnequal)).leftPad(count: 8, padding: " ")
            print("| \(tS) | \(tSince) | \(currentIsUnequal ? "X" : " ") | \(current.hexString) | \(current.binString)")
        }
    }
}
