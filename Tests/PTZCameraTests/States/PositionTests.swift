//
//  PositionTests.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import XCTest
import PTZMessaging
@testable import PTZCamera

final class PositionTests: XCTestCase {
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

    func testAutoFocusRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZAutoFocusState.self, values: [.on, .off], on: camera)
        validateMessageBytes(PTZAutoFocusState(.off), "83 42 09 00")
    }

    func testFocusRequests() throws {
        let camera = try Self.buildCamera()
        validateModeCondition(
            request: try camera.setFocus(.random),
            errorPrecondition: try camera.setAutoFocus(.on),
            successPrecondition: try camera.setAutoFocus(.off)
        )
        validateStateRW(PTZFocusState.self, values: PTZFocus.allCases.pick(10), on: camera)
        validateMessageBytes(PTZFocusState(.mid), "84 43 03 03 78")
    }

    func testFocusActionRequests() throws {
        let camera = try Self.buildCamera()
        validateStateWO(PTZFocusAction.self, values: PTZNone.allCases, on: camera)
        validateMessageBytes(PTZFocusAction(), "82 45 13")
    }

    func testMoveFocusRequests() throws {
        let camera = try Self.buildCamera()
        validateModeCondition(
            request: try camera.startMoveFocus(.default, for: .near),
            errorPrecondition: try camera.setAutoFocus(.on),
            successPrecondition: try camera.setAutoFocus(.off)
        )
        validateStateWO(PTZMoveFocusAction.self, variants: [.far, .near, .stop], values: [.min, .mid, .max], on: camera, sleep: 0.5)
        validateMessageBytes(PTZMoveFocusAction(.default, for: .near), "83 45 0A 01")
    }

    func testMovePanRequests() throws {
        let camera = try Self.buildCamera()
        validateStateWO(PTZMovePanAction.self, variants: [.left, .right, .stop], values: [.min, .mid, .max], on: camera)
        validateMessageBytes(PTZMovePanAction(.default, for: .left), "83 45 01 17")
    }

    func testMoveTiltRequests() throws {
        let camera = try Self.buildCamera()
        validateStateWO(PTZMoveTiltAction.self, variants: [.up, .down, .stop], values: [.min, .mid, .max], on: camera)
        validateMessageBytes(PTZMoveTiltAction(.default, for: .up), "83 45 03 17")
    }

    func testMoveZoomRequests() throws {
        let camera = try Self.buildCamera()
        validateStateWO(PTZMoveZoomAction.self, variants: [.in, .out, .stop], values: [.min, .mid, .max], on: camera, sleep: 0.5)
        validateMessageBytes(PTZMoveZoomAction(.default, for: .out), "83 45 0D 01")
    }
    
    func testPanRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZPanState.self, values: PTZPan.allCases.pick(10), on: camera)
        validateMessageBytes(PTZPanState(.mid), "84 43 04 07 68")
    }

    func testPositionRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZPositionState.self, values: [.random(), .random(), .random()], on: camera)
        validateMessageBytes(PTZPositionState(.init(pan: .mid, tilt: .mid, zoom: .min)), "8D 41 51 24 00 03 68 00 00 7A 03 00 00 40")
    }

    func testPresetRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZPresetState.self, variants: PTZPreset.allCases, values: [.random(), .random(), .random()], on: camera)
        validateMessageBytes(PTZPositionState(.init(pan: .mid, tilt: .mid, zoom: .min)), "8D 41 51 24 00 03 68 00 00 7A 03 00 00 40")
    }

    func testTiltRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZTiltState.self, values: PTZTilt.allCases.pick(10), on: camera)
        validateMessageBytes(PTZTiltState(.mid), "84 43 05 01 7A")
    }
    
    func testZoomRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZZoomState.self, values: PTZZoom.allCases.pick(10), on: camera)
        validateMessageBytes(PTZZoomState(.mid), "84 43 02 08 7A")
    }
}
