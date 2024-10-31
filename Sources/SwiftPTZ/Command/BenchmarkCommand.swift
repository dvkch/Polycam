//
//  BenchmarkCommand.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation
import ArgumentParser

struct BenchmarkCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "benchmark")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    @Option(name: .customLong("duration"), help: "Benchmark duration in seconds")
    var duration: Int = 60
    
    func run(camera: Camera) throws(CameraError) {
        camera.logLevel = .error
        
        // we had some issues were working around timings would fuck up the reading of the hello reply, let's make sure it is still working properly
        _ = try camera.get(PTZHelloState.self)
        
        // proper benchmarking
        let d = Date()
        var count = 0
        while Date().timeIntervalSince(d) < TimeInterval(duration) {
            try camera.set(PTZSharpnessState(.mid))
            count += 1
        }
        print(count, "requests")
        print(count / duration, "rps")
   }
}
