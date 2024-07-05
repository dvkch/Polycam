//
//  RequestsTests.swift
//
//
//  Created by syan on 03/07/2024.
//

import Foundation

import XCTest
@testable import SwiftPTZ

final class RequestsTests: XCTestCase {
    override class func tearDown() {
        super.tearDown()
        buildCamera().powerOff()
    }
    
    static func buildCamera() -> Camera {
        let serial = try! Serial(name: .firstAvailable!, tag: "PTZ", logLevel: .info)
        let camera = Camera(serial: serial, logLevel: .info, powerOffAfterUse: false)
        return camera
    }

    func testBacklightCompensationRequests() {
        let camera = Self.buildCamera()
        for backlightCompensation in PTZBool.testValues {
            let replySet = camera.sendRequest(PTZRequestSetBacklightCompensation(enabled: backlightCompensation.rawValue))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetBacklightCompensation())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyBacklightCompensation)
            XCTAssertEqual((replyGet[1] as! PTZReplyBacklightCompensation).enabled, backlightCompensation.rawValue)
        }
    }

    func testBrightnessRequests() {
        let camera = Self.buildCamera()
        for brightness in PTZBrightness.testValues {
            let replySet = camera.sendRequest(PTZRequestSetBrightness(brightness: brightness))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetBrightness())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyBrightness)
            XCTAssertEqual((replyGet[1] as! PTZReplyBrightness).brightness, brightness)
        }
    }

    func testGainRedRequests() {
        let camera = Self.buildCamera()
        for gain in PTZGain.testValues {
            let replySet = camera.sendRequest(PTZRequestSetRedGain(gain: gain))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetRedGain())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyRedGain)
            XCTAssertEqual((replyGet[1] as! PTZReplyRedGain).gain, gain)
        }
    }

    func testGainBlueRequests() {
        let camera = Self.buildCamera()
        for gain in PTZGain.testValues {
            let replySet = camera.sendRequest(PTZRequestSetBlueGain(gain: gain))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetBlueGain())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyBlueGain)
            XCTAssertEqual((replyGet[1] as! PTZReplyBlueGain).gain, gain)
        }
    }

    func testHelloRequest() {
        let camera = Self.buildCamera()
        let replyHello = camera.sendRequest(PTZRequestHelloMPTZ11())
        XCTAssertEqual(replyHello.count, 2)
        XCTAssertTrue(replyHello[0] is PTZReplyAck)
        XCTAssertTrue(replyHello[1] is PTZReplyHelloMPTZ11)
    }

    func testInvertedModeRequests() {
        let camera = Self.buildCamera()
        for invertedMode in PTZBool.testValues {
            let replySet = camera.sendRequest(PTZRequestSetInvertedMode(enabled: invertedMode.rawValue))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetInvertedMode())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyInvertedMode)
            XCTAssertEqual((replyGet[1] as! PTZReplyInvertedMode).enabled, invertedMode.rawValue)
        }
    }

    func testLedModeRequests() {
        #warning("Fix LED MODE")
        let camera = Self.buildCamera()
        for mode in PTZLedMode.testValues {
            let replySet = camera.sendRequest(PTZRequestSetLedMode(mode: mode))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetLedMode())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyLedMode)
            XCTAssertEqual((replyGet[1] as! PTZReplyLedMode).mode, mode)
        }
    }

    func testPositionRequests() {
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
            let replySet = camera.sendRequest(PTZRequestSetPosition(pan: triplet.0, tilt: triplet.1, zoom: triplet.2))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            Thread.sleep(forTimeInterval: longPauseIndicies.contains(index) ? 2 : 1) // stabilization time
            
            let replyGet = camera.sendRequest(PTZRequestGetPosition())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyPosition)
            XCTAssertEqual((replyGet[1] as! PTZReplyPosition).pan.rawValue, triplet.0.rawValue, accuracy: 0)
            XCTAssertEqual((replyGet[1] as! PTZReplyPosition).tilt.rawValue, triplet.1.rawValue, accuracy: 0)
            XCTAssertEqual((replyGet[1] as! PTZReplyPosition).zoom.rawValue, triplet.2.rawValue, accuracy: 50)
        }
    }
    
    func testSaturationRequests() {
        let camera = Self.buildCamera()
        for saturation in PTZSaturation.testValues {
            let replySet = camera.sendRequest(PTZRequestSetSaturation(saturation: saturation))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetSaturation())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplySaturation)
            XCTAssertEqual((replyGet[1] as! PTZReplySaturation).saturation, saturation)
        }
    }

    func testShutterSpeedRequests() {
        let camera = Self.buildCamera()
        for speed in PTZShutterSpeed.testValues {
            let replySet = camera.sendRequest(PTZRequestSetShutterSpeed(speed: speed))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetShutterSpeed())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyShutterSpeed)
            XCTAssertEqual((replyGet[1] as! PTZReplyShutterSpeed).speed, speed)
        }
    }

    func testStandbyModeRequests() {
        #warning("TODO: test differently, this is not a proper state")
        let camera = buildCamera()
        /*
        for mode in PTZStandbyMode.testValues {
            let replySet = camera.sendRequest(PTZRequestSetStandbyMode(mode: .off))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetStandbyMode())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyStandbyMode)
            XCTAssertEqual((replyGet[1] as! PTZReplyStandbyMode).mode, mode)
        }
         */
    }

    func testVideoOutputRequests() {
#warning("TODO: parse 93 40 01 00 error")
#warning("TODO: fix video output mode")
        let camera = Self.buildCamera()
        for mode in PTZVideoOutputMode.testValues {
            let replySet = camera.sendRequest(PTZRequestSetVideoOutputMode(mode: mode))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetVideoOutputMode())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyVideoOutputMode)
            XCTAssertEqual((replyGet[1] as! PTZReplyVideoOutputMode).mode, mode)
        }
    }

    func testVolumeRequests() {
        #warning("TODO: check if there are more possible volumes, and if a mic is actually present and accessible through HDMI")
        let camera = Self.buildCamera()
        for volume in PTZVolume.testValues {
            let replySet = camera.sendRequest(PTZRequestSetVolume(volume: volume))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetVolume())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyVolume)
            XCTAssertEqual((replyGet[1] as! PTZReplyVolume).volume, volume)
        }
    }

    func testWhiteBalanceRequests() {
        #warning("TODO: parse 93 40 01 12")
        #warning("TODO: make manual calibration work")
        let camera = Self.buildCamera()
        for mode in PTZWhiteBalance.testValues {
            let replySet = camera.sendRequest(PTZRequestSetWhiteBalance(mode: mode))
            XCTAssertEqual(replySet.count, 2)
            XCTAssertTrue(replySet[0] is PTZReplyAck)
            XCTAssertTrue(replySet[1] is PTZReplyExecuted)
            
            let replyGet = camera.sendRequest(PTZRequestGetWhiteBalance())
            XCTAssertEqual(replyGet.count, 2)
            XCTAssertTrue(replyGet[0] is PTZReplyAck)
            XCTAssertTrue(replyGet[1] is PTZReplyWhiteBalance)
            XCTAssertEqual((replyGet[1] as! PTZReplyWhiteBalance).mode, mode)
        }

        let replySetManual = camera.sendRequest(PTZRequestSetWhiteBalance(mode: .auto))
        XCTAssertEqual(replySetManual.count, 2)
        XCTAssertTrue(replySetManual[0] is PTZReplyAck)
        XCTAssertTrue(replySetManual[1] is PTZReplyExecuted)

        let replyCalibrateManual = camera.sendRequest(PTZRequestStartManualWhiteBalanceCalibration())
        XCTAssertEqual(replyCalibrateManual.count, 2)
        XCTAssertTrue(replyCalibrateManual[0] is PTZReplyAck)
        XCTAssertTrue(replyCalibrateManual[1] is PTZReplyExecuted)
    }
}
