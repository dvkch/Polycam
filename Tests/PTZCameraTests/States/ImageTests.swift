//
//  ImageTests.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import XCTest
import PTZMessaging
@testable import PTZCamera

final class ImageTests: XCTestCase {
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

    func testGreyscaleRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZGreyscaleState.self, values: [.on, .off], on: camera)
        validateMessageBytes(PTZGreyscaleState(.off), "83 41 3A 01")
    }

    func testInvertedRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZInvertedState.self, values: [.on, .off], on: camera)
        validateMessageBytes(PTZInvertedState(.off), "83 41 3E 00")
    }

    func testMireRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZMireState.self, values: [.on, .off], on: camera)
        validateMessageBytes(PTZMireState(.off), "83 41 10 00")
    }

    func testNoiseReductionRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZNoiseReductionState.self, values: [.off, .on], on: camera)
        validateMessageBytes(PTZNoiseReductionState(.off), "83 41 3C 00")
    }

    func testSensorSmoothingRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZSensorSmoothingState.self, values: [.off, .on], on: camera)
        validateMessageBytes(PTZSensorSmoothingState(.off), "83 41 3B 00")
    }

    func testVideoOutputRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZVideoOutputState.self, values: PTZVideoOutput.allCases, on: camera)
        validateMessageBytes(PTZVideoOutputState(.resolution1080p60), "83 41 13 1A")
    }

    func testVignetteCorrectionRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZVignetteCorrectionState.self, values: [.off, .on], on: camera)
        validateMessageBytes(PTZVignetteCorrectionState(.off), "83 41 3D 00")
    }
}
