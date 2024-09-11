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
        let testSettersBool: [TestCommand] = [
            //.init(command: (0x41, 0x0B), kind: .bool, originalValue: 0x00),
            //.init(command: (0x41, 0x24), kind: .bool, originalValue: 0x01), // small movements up down      // test 2: changes brightness
            //.init(command: (0x41, 0x34), kind: .bool, originalValue: 0x01), // lighting (removes yellow ?)  // test 2: changes brightness
            //.init(command: (0x41, 0x3B), kind: .bool, originalValue: 0x01), // stars
            //.init(command: (0x41, 0x3C), kind: .bool, originalValue: 0x01), // iso? gives WAY more noise
            //.init(command: (0x41, 0x3D), kind: .bool, originalValue: 0x01),
            //.init(command: (0x41, 0x72), kind: .bool, originalValue: 0x00),
            //.init(command: (0x42, 0x22), kind: .bool, originalValue: 0x01),
        ]
        
        let testSettersInt: [TestCommand] = [
            /*
            .init(command: (0x41, 0x01), kind: .int,  originalValue: 0x00),
            .init(command: (0x41, 0x02), kind: .int,  originalValue: 0x01), // from 0 to 3
            .init(command: (0x41, 0x23), kind: .int,  originalValue: 0x00), // focus ? => supporte une valeur int en argument
            .init(command: (0x41, 0x32), kind: .int,  originalValue: 128), // brightness-ish, image goes washed up 76 to 01 0A
            .init(command: (0x43, 0x40), kind: .int,  originalValue: 128), // mode condition
            .init(command: (0x43, 0x41), kind: .int,  originalValue: 128), // mode condition
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
             */
        ]

        let testActions: [TestCommand] = [
            /*
            .init(command: (0x45, 0x32), kind: .action, originalValue: nil), // 00 and 01 executed, other ones fail ===> seems to pause the camera for 00, resumes for 01
            .init(command: (0x45, 0x71), kind: .action, originalValue: nil), // mode condition, no arg maybe used with 01 71 ?
             */
        ]
        
        camera.logLevel = .error
        
        try runTimersLoop(camera: camera)
    }
    
    func runTimersLoop(camera: Camera) throws {
        camera.logLevel = .error

        let position = PTZRequestSetPosition(pan: .init(rawValue: 0), tilt: .init(rawValue: 0), zoom: .init(rawValue: PTZPositionZoom.minValue))
        camera.sendRequest(position)
        
        let times: [(UInt32, UInt32)] = [
            (0x7E,   0x81),
            (0xFE,   0x101),
            (0x7FFE, 0x8001),
            (0xFFFE, 0x10001),
            (0x7FFFFE, 0x800001),
            (0xFFFFFE, 0x1000001),
            (0x7FFFFFFE, 0x80000001),
            (0xFFFFFFFE, 0x01)
        ]
        
        for (tStart, tEnd) in times {
            print("-------------")
            camera.sendRequest(PTZRequestSetClock(clock: .clock1, time: tStart))
            
            let d = Date()
            var prevBytes: Bytes = []
            while Date().timeIntervalSince(d) < 5 {
                let (bytes, reply) = camera.sendRequest2(PTZRequestGetClock(clock: .clock1))
                guard bytes != prevBytes else { continue }
                prevBytes = bytes
                let time = (reply.last as! PTZReplyClock).time
                print(bytes.stringRepresentation, " > ", time)
            }
        }
    }
}

extension TesterCommand {
    struct TestCommand {
        let command: (UInt8, UInt8)
        let kind: Kind
        let originalValue: Int?
        
        enum Kind {
            case get, bool, int, action
        }
        
        var testValues: [Int?] { 
            switch kind {
            case .get: [nil]
            case .bool: [nil, 0x00, 0x01]
            case .int:  [nil, 0x00, 0x01, 2, 3, 4, 5, 6, 7, 8, 9, 10] + [100, 120, 150] // TODO: Array(100..<150)
            case .action: [nil, 0x00, 0x01, 2, 3, 4, 5, 6, 7, 8, 9, 10]
            }
        }
    }
    
    func testCommand(_ testCommand: TestCommand, on camera: Camera, after: () -> ()) {
        for testValue in testCommand.testValues + [testCommand.originalValue] {
            let req = PTZUnknownRequest(commandBytes: [testCommand.command.0, testCommand.command.1], arg: testValue)
            let reply = camera.sendRequest(req)
            guard reply.last is PTZReplyExecuted else { continue }

            print("===", req.bytes.stringRepresentation, "===")
            Thread.sleep(forTimeInterval: 3)
            after()
        }
    }
}
