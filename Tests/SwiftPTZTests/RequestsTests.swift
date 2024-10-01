//
//  RequestsTests.swift
//
//
//  Created by syan on 03/07/2024.
//

import Foundation

import XCTest
@testable import SwiftPTZ

#warning("complete test coverage with new states and actions")
#warning("add tests for actual byte responses")
final class RequestsTests: XCTestCase {
    override class func tearDown() {
        super.tearDown()
        #warning("reinstate powerinf the camera off")
        //buildCamera().powerOff()
    }
    
    static func buildCamera() -> Camera {
        return try! Camera(serial: .firstAvailable!, logLevel: .info, powerOffAfterUse: false)
    }

    func testBacklightCompensationRequests() throws(CameraError) {
        let camera = Self.buildCamera()
        print("-----------")
        for backlightCompensation in PTZBool.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetBacklightCompensation(enabled: backlightCompensation))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetBacklightCompensation())
            XCTAssertEqual(replyGet.enabled, backlightCompensation)
        }
    }

    func testBrightnessRequests() throws {
        let camera = Self.buildCamera()
        for brightness in PTZBrightness.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetBrightness(brightness: brightness))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetBrightness())
            XCTAssertEqual(replyGet.brightness, brightness)
        }
    }
    
    func testClockRequests() throws {
        let camera = Self.buildCamera()

        let testTimes: [(UInt32, UInt32)] = [
            (0x7E,       0x80),
            (0xFE,       0x100),
            (0x7FFE,     0x8000),
            (0xFFFE,     0x10000),
            (0x7FFFFE,   0x800000),
            (0xFFFFFE,   0x1000000),
            (0x7FFFFFFE, 0x80000000),
            (0xFFFFFFFE, 0x00)
        ]
        
        for (tStart, tEnd) in testTimes {
            try camera.sendRequest(PTZRequestSetClock(clock: .clock1, time: tStart))
            try camera.sendRequest(PTZRequestSetClock(clock: .clock2, time: tStart))
            
            let d = Date()
            var clock1Success = false
            var clock2Success = false

            while Date().timeIntervalSince(d) < 5 && (!clock1Success || !clock2Success) {
                let t1 = try camera.get(PTZRequestGetClock(clock: .clock1)).time
                let t2 = try camera.get(PTZRequestGetClock(clock: .clock2)).time
                clock1Success ||= t1 == tEnd
                clock2Success ||= t2 == tEnd
            }
            XCTAssertTrue(clock1Success, "Clock 1 did not increase as expected")
            XCTAssertTrue(clock2Success, "Clock 2 did not increase as expected")
        }
    }

    func testGainRedRequests() throws {
        let camera = Self.buildCamera()
        for gain in PTZGain.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetRedGain(gain: gain))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetRedGain())
            XCTAssertEqual(replyGet.gain, gain)
        }
    }

    func testGainBlueRequests() throws {
        let camera = Self.buildCamera()
        for gain in PTZGain.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetBlueGain(gain: gain))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetBlueGain())
            XCTAssertEqual(replyGet.gain, gain)
        }
    }

    func testHelloRequest() throws {
        let camera = Self.buildCamera()
        let replyHello = try camera.get(PTZRequestHelloMPTZ11())
        XCTAssertEqual(replyHello.description, "YO")
    }

    func testInvertedModeRequests() throws {
        let camera = Self.buildCamera()
        for invertedMode in PTZBool.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetInvertedMode(enabled: invertedMode))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetInvertedMode())
            XCTAssertEqual(replyGet.enabled, invertedMode)
        }
    }

    func testIrisLevelRequests() throws {
        let camera = Self.buildCamera()
        
        try camera.sendRequest(PTZRequestSetGainMode(gain: .auto))
        let replyAuto = try camera.sendRequest(PTZRequestSetIrisLevel(irisLevel: .mid))
        XCTAssertTrue(replyAuto is PTZReplyNotExecuted)
        XCTAssertEqual((replyAuto as! PTZReplyNotExecuted).error, .modeCondition)

        try camera.sendRequest(PTZRequestSetGainMode(gain: .gain0dB))
        for irisLevel in PTZIrisLevel.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetIrisLevel(irisLevel: irisLevel))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetIrisLevel())
            XCTAssertEqual(replyGet.irisLevel, irisLevel)
        }
    }

    func testLedModeRequests() throws {
        let camera = Self.buildCamera()
        for color in PTZLedColor.testValues {
            for mode in PTZLedMode.testValues {
                let replySet = try camera.sendRequest(PTZRequestSetLedMode(color: color, mode: mode))
                XCTAssertTrue(replySet is PTZReplyExecuted)
                
                let replyGet = try camera.get(PTZRequestGetLedMode())
                XCTAssertEqual(replyGet.color, color)
                XCTAssertEqual(replyGet.mode, mode)
            }
        }
    }

    func testPositionRequests() throws {
        let camera = Self.buildCamera()
        var triplets = [(PTZPositionPan, PTZPositionTilt, PTZPositionZoom)]()
        var longPauseIndicies = [Int]()
        
        longPauseIndicies.append(triplets.count)
        for pan in PTZPositionPan.testValues {
            triplets.append((pan, .init(rawValue: 0), .init(rawValue: 0)))
        }

        longPauseIndicies.append(triplets.count)
        for tilt in PTZPositionTilt.testValues {
            triplets.append((.init(rawValue: 0), tilt, .init(rawValue: 0)))
        }

        longPauseIndicies.append(triplets.count)
        for zoom in PTZPositionZoom.testValues {
            triplets.append((.init(rawValue: 0), .init(rawValue: 0), zoom))
        }

        for (index, triplet) in triplets.enumerated() {
            let replySet = try camera.sendRequest(PTZRequestSetPosition(pan: triplet.0, tilt: triplet.1, zoom: triplet.2))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            Thread.sleep(forTimeInterval: longPauseIndicies.contains(index) ? 2 : 1) // stabilization time
            
            let replyGet = try camera.get(PTZRequestGetPosition())
            XCTAssertEqual(replyGet.pan.rawValue, triplet.0.rawValue, accuracy: 0)
            XCTAssertEqual(replyGet.tilt.rawValue, triplet.1.rawValue, accuracy: 0)
            XCTAssertEqual(replyGet.zoom.rawValue, triplet.2.rawValue, accuracy: 50)
        }
    }
    
    func testSaturationRequests() throws {
        let camera = Self.buildCamera()
        for saturation in PTZSaturation.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetSaturation(saturation: saturation))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetSaturation())
            XCTAssertEqual(replyGet.saturation, saturation)
        }
    }

    func testSharpnessRequests() throws {
        let camera = Self.buildCamera()
        for sharpness in PTZSharpness.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetSharpness(sharpness: sharpness))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetSharpness())
            XCTAssertEqual(replyGet.sharpness, sharpness)
        }
    }

    func testShutterSpeedRequests() throws {
        let camera = Self.buildCamera()
        for speed in PTZShutterSpeed.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetShutterSpeed(speed: speed))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetShutterSpeed())
            XCTAssertEqual(replyGet.speed, speed)
        }
    }

    func testStandbyModeRequests() {
        Self.buildCamera().powerOff()
        Self.buildCamera().powerOn()
    }

    func testVideoOutputRequests() throws {
#warning("TODO: fix video output mode")
        /*
        let camera = Self.buildCamera()
        for mode in PTZVideoOutputMode.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetVideoOutputMode(mode: mode))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetVideoOutputMode())
            XCTAssertEqual(replyGet.mode, mode)
        }
         */
    }

    func testVolumeRequests() throws {
        let camera = Self.buildCamera()
        for volume in PTZVolume.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetVolume(volume: volume))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetVolume())
            XCTAssertEqual(replyGet.volume, volume)
        }
    }

    func testWhiteBalanceRequests() throws {
        let camera = Self.buildCamera()
        for mode in PTZWhiteBalance.testValues {
            let replySet = try camera.sendRequest(PTZRequestSetWhiteBalance(mode: mode))
            XCTAssertTrue(replySet is PTZReplyExecuted)
            
            let replyGet = try camera.get(PTZRequestGetWhiteBalance())
            XCTAssertEqual(replyGet.mode, mode)
        }

        let replySetAuto = try camera.sendRequest(PTZRequestSetWhiteBalance(mode: .auto))
        XCTAssertTrue(replySetAuto is PTZReplyExecuted)

        let replyCalibrateAuto = try camera.sendRequest(PTZRequestStartManualWhiteBalanceCalibration())
        XCTAssertTrue((replyCalibrateAuto as? PTZReplyNotExecuted)?.error == .modeCondition)

        let replySetManual = try camera.sendRequest(PTZRequestSetWhiteBalance(mode: .manual))
        XCTAssertTrue(replySetManual is PTZReplyExecuted)

        let replyCalibrateManual = try camera.sendRequest(PTZRequestStartManualWhiteBalanceCalibration())
        XCTAssertTrue(replyCalibrateManual is PTZReplyExecuted)
    }
}
