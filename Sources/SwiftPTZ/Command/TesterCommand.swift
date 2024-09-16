//
//  TesterCommand.swift
//
//
//  Created by syan on 10/09/2024.
//

import Foundation
import ArgumentParser

struct TesterCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "tester")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    func run(camera: Camera) throws {
        let testSetters: [TestCommand] = [
            .init(command: (0x41, 0x01), kind: .custom([nil] + Array(0...0x0A).pick(count: 2)),  originalValue: 0x00),
            .init(command: (0x41, 0x02), kind: .custom([nil, 0, 1, 2, 3]),  originalValue: 0x01), // from 0 to 3
            .init(command: (0x41, 0x0B), kind: .bool, originalValue: 0x00),
            .init(command: (0x41, 0x14), kind: .bool, originalValue: 0x00),
            .init(command: (0x41, 0x23), kind: .custom([nil] + Array(0...0x0A).pick(count: 2)),  originalValue: 0x00), // focus ? => supporte une valeur int en argument
            .init(command: (0x41, 0x24), kind: .bool, originalValue: 0x01), // small movements up down      // test 2: changes brightness
            .init(command: (0x41, 0x32), kind: .custom([nil] + Array(0x76...0x8A).pick(count: 2)),  originalValue: 128), // brightness-ish, image goes washed up 76 to 01 0A
            .init(command: (0x41, 0x34), kind: .bool, originalValue: 0x01), // lighting (removes yellow ?)  // test 2: changes brightness
            .init(command: (0x41, 0x3B), kind: .bool, originalValue: 0x01), // stars
            .init(command: (0x41, 0x3C), kind: .bool, originalValue: 0x01), // iso? gives WAY more noise
            .init(command: (0x41, 0x3D), kind: .bool, originalValue: 0x01),
            .init(command: (0x41, 0x71), kind: .bool, originalValue: 0x00),
            .init(command: (0x41, 0x72), kind: .bool, originalValue: 0x00),

            .init(command: (0x42, 0x22), kind: .bool, originalValue: 0x01),

            //.init(command: (0x43, 0x02), kind: .custom(Array(0x00...0x7FFF)), originalValue: 08 7A), // zooms    0040 -> 1135
            //.init(command: (0x43, 0x03), kind: .custom(Array(0x00...0x7FFF)), originalValue: 05 23), // focus    0170 -> 0600
            //.init(command: (0x43, 0x04), kind: .custom(Array(0x00...0x7FFF)), originalValue: 07 68), // pan/tilt 0000 -> 0F50
            //.init(command: (0x43, 0x05), kind: .custom(Array(0x00...0x7FFF)), originalValue: 01 7A), // pan/tilt 0000 -> 0374
            //.init(command: (0x43, 0x40), kind: .custom(Array(0x60...0x9F)),  originalValue: 128), // white balance manual, adjust green to pink, from 60 to 01 1F
            //.init(command: (0x43, 0x41), kind: .custom(Array(0x60...0x9F)),  originalValue: 128), // white balance manual, adjust yellow to blue, from 60 to 01 1F

            .init(command: (0x43, 0x50), kind: .int,  originalValue: 128), // amount of red, 7B to 01 05
            .init(command: (0x43, 0x51), kind: .int,  originalValue: 128), // same, veeeeeery small increments
            .init(command: (0x43, 0x52), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x53), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x54), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x55), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x56), kind: .int,  originalValue: 128), // amount of red (smaller increments)
            .init(command: (0x43, 0x57), kind: .int,  originalValue: 128), // amount of green, smaller increments)
            .init(command: (0x43, 0x58), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x59), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x5A), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x5B), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x5C), kind: .int,  originalValue: 128), // saturation ? 76 - 01 0A
            .init(command: (0x43, 0x5D), kind: .int,  originalValue: 128), // changes color a weeee bit too, amount of yellow?
            .init(command: (0x43, 0x5E), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x5F), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x60), kind: .int,  originalValue: 128),
            .init(command: (0x43, 0x61), kind: .int,  originalValue: 128),
        ]
        
        /* ************************************************************************** */
        
        camera.logLevel = .error

        let testStates: [any PTZRequest] = [
            PTZRequestSetWhiteBalance(mode: .manual),
            PTZRequestSetWhiteBalance(mode: .temp2300K),
            PTZRequestSetWhiteBalance(mode: .temp2856K),
            PTZRequestSetWhiteBalance(mode: .temp3450K),
            PTZRequestSetWhiteBalance(mode: .temp4230K),
            PTZRequestSetWhiteBalance(mode: .temp5200K),
            PTZRequestSetWhiteBalance(mode: .temp6504K),
            PTZRequestSetWhiteBalance(mode: .temp6504K),
            PTZRequestSetWhiteBalance(mode: .auto),
            PTZRequestSetAutoExposure(enabled: .on),
            PTZRequestSetAutoExposure(enabled: .off),
            PTZRequestSetMireMode(enabled: .on),
            PTZRequestSetMireMode(enabled: .off),
            PTZRequestSetLedMode(color: .off, mode: .off),
            PTZRequestSetLedMode(color: .yellow, mode: .on),
            PTZRequestSetVolume(volume: .init(rawValue: PTZVolume.minValue)),
            PTZRequestSetVolume(volume: .default),
            PTZRequestSetGainMode(gain: .gain0dB),
            PTZRequestSetGainMode(gain: .auto),
            PTZRequestSetBrightness(brightness: .init(rawValue: PTZBrightness.minValue)),
            PTZRequestSetBrightness(brightness: .default),
            PTZRequestSetInvertedMode(enabled: .on),
            PTZRequestSetInvertedMode(enabled: .off),
            PTZRequestSetAutoFocus(enabled: .off),
            PTZRequestSetAutoFocus(enabled: .on),
            PTZRequestSetShutterSpeed(speed: .fps50),
            PTZRequestSetShutterSpeed(speed: .fps400),
            PTZRequestSetShutterSpeed(speed: .auto),
            PTZRequestSetBacklightCompensation(enabled: .on),
            PTZRequestSetBacklightCompensation(enabled: .off),
            PTZRequestSetSharpness(sharpness: .init(rawValue: PTZSharpness.minValue)),
            PTZRequestSetSharpness(sharpness: .default),
            PTZRequestSetSaturation(saturation: .init(rawValue: PTZSaturation.minValue)),
            PTZRequestSetSaturation(saturation: .default),
            PTZRequestSetRedGain(gain: .init(rawValue: PTZGain.minValue)),
            PTZRequestSetRedGain(gain: .default),
            PTZRequestSetBlueGain(gain: .init(rawValue: PTZGain.minValue)),
            PTZRequestSetBlueGain(gain: .default),
        ]

        let allRequests = testStates + testSetters.map(\.requests).flatten
        let cmdsToMakeWork: [TestCommand] = [
            .init(command: (0x41, 0x14), kind: .custom(Array(0x00...0xFF)), originalValue: 0x00),
            .init(command: (0x41, 0x71), kind: .custom(Array(0x00...0xFF)), originalValue: 0x00),
            .init(command: (0x43, 0x26), kind: .custom(Array(0x00...0xFF)), originalValue: 0x46),

            //.init(command: (0x43, 0x3F), kind: .custom([0x5A, 0x64]), originalValue: 0x5A),
        ]
        
        try camera.sendRequest(PTZRequestSetAutoFocus(enabled: false))
        for register: UInt8 in [3] {
            print("-----------------------------------")
            for arg0: UInt8? in [nil] + Array(0..<0x7F) {
                for arg1: UInt8? in [nil] + Array(0..<0x7F) {
                    let req = PTZUnknownRequest(commandBytes: [0x43, register, arg0, arg1].compactMap({ $0 }), arg: nil)
                    try testRequest(req, on: camera, duration: 0.01) { _ in
                        print("->", req.bytes.stringRepresentation)
                    }
                }
            }
        }
        /*
        for test in allRequests {
            try testRequest(test, on: camera, duration: 0.1) { req in
                print("===", req.bytes.stringRepresentation, "===")
                for cmd in cmdsToMakeWork {
                    try testCommand(cmd, on: camera, duration: 0.1) { r in
                        print("-------> YOOOOOOO", r.bytes.stringRepresentation)
                    }
                }
            }
        }
         */
    }
}

extension TesterCommand {
    struct TestCommand {
        let command: (UInt8, UInt8)
        let kind: Kind
        let originalValue: Int?
        
        enum Kind {
            case get, bool, int, action, custom([Int?])
        }
        
        var testValues: [Int?] { 
            switch kind {
            case .get:                  [nil]
            case .bool:                 [nil, 0x00, 0x01]
            case .int:                  [nil, 0x00, 0x01, 2, 3, 4, 5, 6, 7, 8, 9, 10] + Array(60..<67) + Array(100..<150)
            case .action:               [nil, 0x00, 0x01, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            case .custom(let values):   values
            }
        }
        
        var requests: [PTZUnknownRequest] {
            (testValues + [originalValue]).map {
                PTZUnknownRequest(commandBytes: [command.0, command.1], arg: $0)
            }
        }
    }
    
    func testCommand(_ testCommand: TestCommand, on camera: Camera, duration: TimeInterval, after: (any PTZRequest) throws -> ()) throws {
        for request in testCommand.requests {
            try testRequest(request, on: camera, duration: duration, after: after)
        }
    }
    
    func testRequest(_ request: any PTZRequest, on camera: Camera, duration: TimeInterval, after: (any PTZRequest) throws -> ()) throws {
        let reply = try camera.sendRequest(request)
        guard reply is PTZReplyExecuted else {
            //print("=>", reply)
            return
        }

        Thread.sleep(forTimeInterval: duration)
        try after(request)
    }
}
