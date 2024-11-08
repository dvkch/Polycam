//
//  FunctionTests.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import XCTest
import PTZMessaging
@testable import PTZCamera

final class FunctionTests: XCTestCase {
    override class func setUp() {
        super.setUp()

        Camera.registerKnownStates()

        // Give a known initial state
        let camera = try! buildCamera()
        try! camera.powerOn()
    }

    static func buildCamera() throws(CameraError) -> Camera {
        let camera = try Camera(serial: .firstAvailable!, logLevel: .error)
        try camera.powerOnIfNeeded()
        return camera
    }

    func testClockRequests() throws {
        let camera = try Self.buildCamera()

        let testTimes: [(tStart: UInt32, tEnd: UInt32, tStartHex: String, tEndHex: String)] = [
            (0x7E,       0x80,       "8D 41 5D 00 00 00 00 7E 00 00 00 00 00 00", "8D 41 5D 08 00 00 00 00 00 00 00 00 00 00"),
            (0xFE,       0x100,      "8D 41 5D 08 00 00 00 7E 00 00 00 00 00 00", "8D 41 5D 00 00 00 01 00 00 00 00 00 00 00"),
            (0x7FFE,     0x8000,     "8D 41 5D 08 00 00 7F 7E 00 00 00 00 00 00", "8D 41 5D 04 00 00 00 00 00 00 00 00 00 00"),
            (0xFFFE,     0x10000,    "8D 41 5D 0C 00 00 7F 7E 00 00 00 00 00 00", "8D 41 5D 00 00 01 00 00 00 00 00 00 00 00"),
            (0x7FFFFE,   0x800000,   "8D 41 5D 0C 00 7F 7F 7E 00 00 00 00 00 00", "8D 41 5D 02 00 00 00 00 00 00 00 00 00 00"),
            (0xFFFFFE,   0x1000000,  "8D 41 5D 0E 00 7F 7F 7E 00 00 00 00 00 00", "8D 41 5D 00 01 00 00 00 00 00 00 00 00 00"),
            (0x7FFFFFFE, 0x80000000, "8D 41 5D 0E 7F 7F 7F 7E 00 00 00 00 00 00", "8D 41 5D 01 00 00 00 00 00 00 00 00 00 00"),
            (0xFFFFFFFE, 0x00,       "8D 41 5D 0F 7F 7F 7F 7E 00 00 00 00 00 00", "8D 41 5D 00 00 00 00 00 00 00 00 00 00 00")
        ]
        
        for (tStart, tEnd, tStartHex, tEndHex) in testTimes {
            try camera.setClock(tStart, for: .clock1)
            try camera.setClock(tStart, for: .clock2)
            
            let d = Date()
            var clock1Success = false
            var clock2Success = false

            while Date().timeIntervalSince(d) < 5 && (!clock1Success || !clock2Success) {
                let t1 = try camera.clock(for: .clock1)
                let t2 = try camera.clock(for: .clock2)
                clock1Success = clock1Success || t1 == tEnd
                clock2Success = clock2Success || t2 == tEnd
            }
            XCTAssertTrue(clock1Success, "Clock 1 did not increase as expected")
            XCTAssertTrue(clock2Success, "Clock 2 did not increase as expected")

            validateMessageBytes(PTZClockState(tStart, for: .clock1), tStartHex)
            validateMessageBytes(PTZClockState(tEnd,   for: .clock1), tEndHex)
        }
    }

    func testDevModeRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZDevModeState.self, values: [.off, .on], on: camera)
        validateMessageBytes(PTZDevModeState(.on), "83 41 0B 01")
    }
    
    func testDrunkTestRequests() throws {
        // We can't easily test the DrunkTest action without waiting for 2 full minutes and maybe hurting the camera. Let's just skip it
    }

    func testDrunkTestPhaseRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRO(PTZDrunkTestPhaseState.self, expected: .neverLaunched, on: camera)
    }
    
    func testHelloRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRO(PTZHelloState.self, expected: nil, on: camera)
    }
    
    func testLedRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZLedState.self, values: [.init(color: .blue, mode: .everyHalfSecond), .init(color: .red, mode: .on)], on: camera)
        validateMessageBytes(PTZLedState(.init(color: .green, mode: .everyQuarterSecond)), "84 41 21 01 30")
    }
    
    func testLedIntensityRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZLedIntensityState.self, values: [.init(r: 0, g: 50, b: 100), .init(r: 50, g: 50, b: 50)], on: camera)
        validateMessageBytes(PTZLedIntensityState(.init(r: 50, g: 50, b: 50)), "85 41 25 08 08 08")
    }
    
    func testPowerRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZPowerState.self, values: [.sleeping, .on], on: camera, sleep: 5)
        validateMessageBytes(PTZPowerState(.on), "83 41 00 00")
    }
    
    func testResetRequests() throws {
        let camera = try Self.buildCamera()
        validateStateWO(PTZResetAction.self, values: PTZReset.allCases, on: camera, sleep: 2)
        while (try? camera.hello()) == nil {
            Thread.sleep(forTimeInterval: 0.5)
        }
        validateMessageBytes(PTZResetAction(.settingsAndMotors), "83 45 32 01")
    }
    
    func testSleepTimeoutRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZSleepTimeoutState.self, values: [30, 90, 1440, 0], on: camera)
        validateMessageBytes(PTZSleepTimeoutState(60), "83 41 01 02")
    }
    
    func testStatisticsRequests() throws {
        let camera = try Self.buildCamera()
        try camera.setDevMode(.on)
        validateStateRO(PTZStatisticsState.self, variants: PTZStatisticsGroup.allCases, expected: nil, on: camera)
    }
}
