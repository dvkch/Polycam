//
//  TesterCommand.swift
//
//
//  Created by syan on 10/09/2024.
//

import Foundation
import ArgumentParser

extension Array {
    func paired(dup: Int) -> [Element] {
        guard count > 1 else { return self }
        return (0..<(count - 1)).map { [self[$0], self[$0 + 1]] * dup }.flatten
    }
}

struct TesterCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "tester")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    func run(camera: Camera) throws(CameraError) {
        camera.logLevel = .error
        try camera.sendRequest(PTZRequestSetDevMode(enabled: .on))
        
        let cmdsToMakeWork: [TestCommand] = [
            .init(command: (0x45, 0x13), kind: .custom([]),  originalValue: nil),
        ]

        for cmd in cmdsToMakeWork * 10 {
            print("-----------", cmd.command)
            for _ in 0..<3 {
                try testCommand(cmd, on: camera, duration: 0) { req, repl in
                    print("----------------")
                    let d = Date()
                    while Date().timeIntervalSince(d) < 10 {
                        print("--->", try! camera.get(PTZRequestGetFocus()).focus)
                    }
                    Thread.sleep(forTimeInterval: 5)
                }
            }
        }
    }
}

extension TesterCommand {
    func testCommand(_ testCommand: TestCommand, on camera: Camera, duration: TimeInterval, after: (PTZUnknownRequest, any PTZReply) throws(CameraError) -> ()) throws(CameraError) {
        for request in testCommand.requests {
            try testRequest(request, on: camera, duration: duration, after: after)
        }
    }
    
    func testRequest<T: PTZRequest>(_ request: T, on camera: Camera, duration: TimeInterval, after: (T, any PTZReply) throws(CameraError) -> ()) throws(CameraError) {
        let reply = try camera.sendRequest(request)
        guard !(reply is PTZReplyFail) && !(reply is PTZReplyNotExecuted) else {
            // print("=>", request.bytes.stringRepresentation, reply)
            return
        }

        Thread.sleep(forTimeInterval: duration)
        try after(request, reply)
    }

}

extension TesterCommand {
    private var unknownCommands: [TestCommand] {
        [
            .init(command: (0x41, 0x01), kind: .custom([nil] + Array(0...0x30).pick(count: 3)),  originalValue: 0x00),
            .init(command: (0x41, 0x02), kind: .custom([nil, 0, 1, 2, 3]),  originalValue: 0x01), // from 0 to 3
            .init(command: (0x41, 0x0C), kind: .bool, originalValue: 0),
            .init(command: (0x41, 0x23), kind: .custom([nil] + Array(0...0x10).pick(count: 3)),  originalValue: 0x00), // focus ? => supporte une valeur int en argument
            .init(command: (0x41, 0x24), kind: .bool, originalValue: 0x01), // small movements up down      // test 2: changes brightness
            .init(command: (0x41, 0x32), kind: .custom([nil] + Array(0x76...0x8A).pick(count: 3)),  originalValue: 128), // brightness-ish, image goes washed up 76 to 01 0A
            .init(command: (0x41, 0x34), kind: .bool, originalValue: 0x01), // lighting (removes yellow ?)  // test 2: changes brightness
            .init(command: (0x41, 0x72), kind: .bool, originalValue: 0x00),

            .init(command: (0x42, 0x22), kind: .bool, originalValue: 0x01),
            
            /*

            .init(command: (0x43, 0x50), kind: .custom([0x7B, 0x8A]),  originalValue: 128), // amount of red, 7B to 01 05
            .init(command: (0x43, 0x51), kind: .custom([0x7B, 0x8A]),  originalValue: 128), // same, veeeeeery small increments
            .init(command: (0x43, 0x52), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x53), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x54), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x55), kind: .custom([0x7B, 0x8A]),  originalValue: 128),

            .init(command: (0x43, 0x56), kind: .custom([0x7B, 0x8A]),  originalValue: 128), // amount of red (smaller increments)
            .init(command: (0x43, 0x57), kind: .custom([0x7B, 0x8A]),  originalValue: 128), // amount of green, smaller increments)
            .init(command: (0x43, 0x58), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x59), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x5A), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x5B), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            
            .init(command: (0x43, 0x5C), kind: .custom([0x7B, 0x8A]),  originalValue: 128), // saturation ? 76 - 01 0A
            .init(command: (0x43, 0x5D), kind: .custom([0x7B, 0x8A]),  originalValue: 128), // changes color a weeee bit too, amount of yellow?
            .init(command: (0x43, 0x5E), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x5F), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x60), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
            .init(command: (0x43, 0x61), kind: .custom([0x7B, 0x8A]),  originalValue: 128),
             
             */
        ]
    }

    private var knownSetters: [any PTZRequest] {
        var testStates: [any PTZRequest] = []
        func addTestState<T: Equatable>(_ request: (T) -> any PTZRequest, _ values: [T]) {
            var uniqueValues: [T] = []
            for v in values.reversed() {
                if !uniqueValues.contains(v) {
                    uniqueValues.append(v)
                }
            }
            for v in uniqueValues.reversed() {
                testStates.append(request(v))
            }
        }

        addTestState(PTZRequestSetAutoExposure.init(enabled:), [PTZBool.off, .on])
        addTestState(PTZRequestSetAutoFocus.init(enabled:), [PTZBool.off, .on])
        addTestState(PTZRequestSetBacklightCompensation.init(enabled:), [PTZBool.off, .on])
        addTestState(PTZRequestSetBrightness.init(brightness:), [PTZBrightness.min, .mid, .max, .default])
        addTestState(PTZRequestSetColors.init(enabled:), [PTZBool.off, .on])
        addTestState(PTZRequestSetFocus.init(focus:), [PTZFocus.min, .mid, .max, .default])
        addTestState(PTZRequestSetGainMode.init(gain:), PTZGainMode.allCases + [.default])
        addTestState(PTZRequestSetRedGain.init(gain:), [PTZColorGain.min, .mid, .max, .default])
        addTestState(PTZRequestSetBlueGain.init(gain:), [PTZColorGain.min, .mid, .max, .default])
        addTestState(PTZRequestSetInvertedMode.init(enabled:), [PTZBool.on, .off])
        addTestState(PTZRequestSetIrisLevel.init(irisLevel:), [PTZIrisLevel.min, .mid, .max, .default])
        addTestState({ PTZRequestSetLedMode(color: .yellow, mode: $0) }, [PTZLedMode.off, .on])
        //addTestState(PTZRequestSetMireMode.init(enabled:), [PTZBool.on, .off])
        addTestState({ PTZRequestSetMove(direction: $0, panTiltSpeed: .speed1, zoomSpeed: .speed1, focusSpeed: .speed1) }, PTZDirection.allCases)
        addTestState(PTZRequestSetNoiseReduction.init(enabled:), [PTZBool.off, .on])
        addTestState(PTZRequestSetPan.init(pan:), [PTZPan.min, .mid, .max, .default])
        addTestState(PTZRequestSetSaturation.init(saturation:), [PTZSaturation.min, .mid, .max, .default])
        addTestState(PTZRequestSetSensorSmoothing.init(enabled:), [PTZBool.off, .on])
        addTestState(PTZRequestSetSharpness.init(sharpness:), [PTZSharpness.min, .mid, .max, .default])
        addTestState(PTZRequestSetShutterSpeed.init(speed:), [PTZShutterSpeed.fps100, .fps1600, .default])
        addTestState(PTZRequestSetTilt.init(tilt:), [PTZTilt.min, .mid, .max, .default])
        addTestState(PTZRequestSetVideoOutputMode.init(mode:), [PTZVideoOutputMode.resolution720p, .default])
        addTestState(PTZRequestSetVignetteCorrection.init(enabled:), [PTZBool.off, .on])
        addTestState(PTZRequestSetVolume.init(volume:), [PTZVolume.unknown1, .unknown2, .default])
        addTestState(PTZRequestSetWhiteBalance.init(mode:), [PTZWhiteBalance.manual, .temp3450K, .auto, .default])
        addTestState(PTZRequestSetWhiteBalanceTemp.init(temp:), [PTZWhiteBalanceTemp.min, .mid, .max, .default])
        addTestState(PTZRequestSetWhiteBalanceTint.init(tint:), [PTZWhiteBalanceTint.min, .mid, .max, .default])
        addTestState(PTZRequestSetWhiteLevel.init(level:), [PTZWhiteLevel.full, .reduced, .default])
        addTestState(PTZRequestSetZoom.init(zoom:), [PTZZoom.min, .mid, .max, .default])

        return testStates
    }
}


extension TesterCommand {
    struct TestCommand {
        let command: (UInt8, UInt8)
        let kind: Kind
        let originalValue: UInt16?
        
        enum Kind {
            case get, bool, int, action, custom([UInt16?])
        }
        
        var testValues: [UInt16?] {
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
}
