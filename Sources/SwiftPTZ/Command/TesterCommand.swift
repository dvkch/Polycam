//
//  TesterCommand.swift
//
//
//  Created by syan on 10/09/2024.
//

import Foundation
import ArgumentParser
import AppKit

struct TesterCommand: CamerableCommand {
    static var configuration: CommandConfiguration = .init(commandName: "tester")
    
    @Option(name: .customLong("serial-device"), help: "PTZ serial device name")
    var serialDevice: String?
    
    func run(camera: Camera) throws(CameraError) {
        camera.logLevel = .error

        try camera.sendRequest(PTZRequestSetDevMode(enabled: .on))
        try camera.sendRequest(PTZRequestSetNoiseReduction(enabled: .on))
        try camera.sendRequest(PTZRequestSetContrast(contrast: .default))
        try camera.sendRequest(PTZRequestSetVignetteCorrection(enabled: .on))
        try camera.sendRequest(PTZRequestSetPosition(pan: .mid, tilt: .init(rawValue: 350), zoom: .mid))
        try camera.sendRequest(PTZRequestSetGainMode(gain: .auto))
        try camera.sendRequest(PTZRequestSetWhiteBalance(mode: .auto))
        
        let cmdsToMakeWork: [[TestCommand]] = [
        ]

        for cmd in cmdsToMakeWork.flatten {
            try camera.sendRequest(PTZUnknownRequest(commandBytes: [cmd.command.0, cmd.command.1], arg: cmd.originalValue))
        }

        for cmdGroup in cmdsToMakeWork {
            for cmd in cmdGroup * 10 {
                print("-----------", cmd.command.0.stringRepresentation, cmd.command.1.stringRepresentation, "---------------")
                speak(cmd.command.1.stringRepresentation)
                for _ in 0..<10 {
                    NSSound.beep()
                    try testCommand(cmd, on: camera, duration: 0.5) { req, repl in
                        //print("--->", req.arg!, UInt8(req.arg!).stringRepresentation)
                    }
                }
            }
            
            for cmd in cmdGroup {
                try camera.sendRequest(PTZUnknownRequest(commandBytes: [cmd.command.0, cmd.command.1], arg: cmd.originalValue))
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
            .init((0x41, 0x01), .custom([nil] + Array(0...0x30).pick(count: 3)), org: 0x00),
            .init((0x41, 0x02), .custom([nil, 0, 1, 2, 3]), org: 0x01), // from 0 to 3
            .init((0x41, 0x0C), .bool, org: 0),
            .init((0x41, 0x23), .custom([nil] + Array(0...0x10).pick(count: 3)),  org: 0x00), // focus ? => supporte une valeur int en argument
            .init((0x41, 0x24), .bool, org: 0x01), // small movements up down      // test 2: changes brightness
            .init((0x41, 0x32), .custom([nil] + Array(0x76...0x8A).pick(count: 3)),  org: 128), // brightness-ish, image goes washed up 76 to 01 0A
            .init((0x41, 0x34), .bool, org: 0x01), // lighting (removes yellow ?)  // test 2: changes brightness
            .init((0x41, 0x72), .bool, org: 0x00),

            .init((0x42, 0x22), .bool, org: 0x01),
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
        
        init(_ command: (UInt8, UInt8), _ kind: Kind, org: UInt16?) {
            self.command = command
            self.kind = kind
            self.originalValue = org
        }
        
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
            (testValues /*+ [originalValue]*/).map {
                PTZUnknownRequest(commandBytes: [command.0, command.1], arg: $0)
            }
        }
    }
}
