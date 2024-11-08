//
//  LightTests.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import XCTest
import PTZMessaging
@testable import PTZCamera

final class LightTests: XCTestCase {
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

    func testAutoExposureRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZAutoExposureState.self, values: [.on, .off], on: camera)
        validateMessageBytes(PTZAutoExposureState(.off), "83 42 11 00")
    }

    func testBacklightCompensationRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZBacklightCompensationState.self, values: [.on, .off], on: camera)
        validateMessageBytes(PTZBacklightCompensationState(.off), "83 42 15 00")
    }

    func testColorGainRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZColorGainState.self, variants: PTZColorGainChannel.allCases, values: PTZColorGain.allCases, on: camera)
        validateMessageBytes(PTZColorGainState(.mid, for: .red), "83 43 42 7F")
    }

    func testEffectiveGainRequests() throws {
        let camera = try Self.buildCamera()
        try camera.setGainMode(.gain6dB)
        validateStateRO(PTZEffectiveGainState.self, expected: 6, on: camera)
        try camera.setGainMode(.auto)
    }

    func testIrisLevelRequests() throws {
        let camera = try Self.buildCamera()
        validateModeCondition(
            request: try camera.setIrisLevel(.random),
            errorPrecondition: try camera.setGainMode(.auto),
            successPrecondition: (try camera.setGainMode(.gain0dB), try camera.setAutoExposure(.off), try camera.setBacklightCompensation(.off)).0
        )
        
        try camera.setWhiteBalance(.manual)
        validateStateRW(PTZIrisLevelState.self, values: PTZIrisLevel.allCases, on: camera)
        validateMessageBytes(PTZIrisLevelState(.mid), "83 43 00 7F")
    }

    func testShutterSpeedRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZShutterSpeedState.self, values: PTZShutterSpeed.allCases, on: camera)
        validateMessageBytes(PTZShutterSpeedState(.auto), "83 42 14 00")
    }

    func testWideDynamicRangeRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZWideDynamicRangeState.self, values: [.off, .on], on: camera)
        validateMessageBytes(PTZWideDynamicRangeState(.on), "83 41 34 01")
    }
}
