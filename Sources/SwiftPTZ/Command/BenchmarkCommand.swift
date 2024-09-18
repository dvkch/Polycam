//
//  BenchmarkCommand.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation
import ArgumentParser

struct BenchmarkCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "batch")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    @Option(name: .customLong("duration"), help: "Benchmark duration in seconds")
    var duration: Int = 60
    
    func run(camera: Camera) throws {
        camera.logLevel = .error
        
        // we had some issues were working around timings would fuck up the reading of the hello reply, let's make sure it is still working properly
        let hello = try camera.sendRequest(PTZRequestHelloMPTZ11())
        guard hello is PTZReplyHelloMPTZ11 else { fatalError("Hello request doesn't work properly") }
        
        // proper benchmarking
        let d = Date()
        var count = 0
        while Date().timeIntervalSince(d) < TimeInterval(duration) {
            try camera.sendRequest(PTZRequestSetSharpness(sharpness: .mid))
            count += 1
        }
        print(count, "requests")
        print(count / duration, "rps")
   }
}
