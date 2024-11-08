//
//  ColorsTests.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import XCTest
import PTZMessaging
@testable import PTZCamera

final class ColorsTests: XCTestCase {
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

    func testBrightnessRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZBrightnessState.self, values: PTZBrightness.allCases, on: camera)
        validateMessageBytes(PTZBrightnessState(.mid), "84 41 33 01 00")
    }

    func testCalibrationHueRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZCalibrationHueState.self, variants: PTZCalibrationRange.allCases, values: PTZCalibrationHue.allCases, on: camera)
        validateMessageBytes(PTZCalibrationHueState(.mid, for: .cyan), "84 43 53 01 00")
    }
    
    func testCalibrationLuminanceRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZCalibrationLuminanceState.self, variants: PTZCalibrationRange.allCases, values: PTZCalibrationLuminance.allCases, on: camera)
        validateMessageBytes(PTZCalibrationLuminanceState(.mid, for: .cyan), "84 43 59 01 00")
    }
    
    func testCalibrationSaturationRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZCalibrationSaturationState.self, variants: PTZCalibrationRange.allCases, values: PTZCalibrationSaturation.allCases, on: camera)
        validateMessageBytes(PTZCalibrationSaturationState(.mid, for: .cyan), "84 43 5F 01 00")
    }
    
    func testCalibrationMatrixRequests() throws {
        let camera = try Self.buildCamera()
        let matrixes = [PTZCalibrationMatrix.random(), .random(), .random()]
        validateStateRW(PTZCalibrationMatrixState.self, values: matrixes, on: camera)
    }
    
    func testContrastRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZContrastState.self, values: PTZContrast.allCases, on: camera)
        validateMessageBytes(PTZContrastState(.mid), "84 41 32 01 00")
    }
    
    func testSaturationRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZSaturationState.self, values: PTZSaturation.allCases, on: camera)
        validateMessageBytes(PTZSaturationState(.mid), "84 43 3E 01 00")
    }
    
    func testSharpnessRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZSharpnessState.self, values: PTZSharpness.allCases, on: camera)
        validateMessageBytes(PTZSharpnessState(.mid), "84 43 3D 01 00")
    }
    
    func testWhiteBalanceRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZWhiteBalanceState.self, values: PTZWhiteBalance.allCases, on: camera)
        validateMessageBytes(PTZWhiteBalanceState(.auto), "83 42 12 01")
    }
    
    func testWhiteBalanceTempRequests() throws {
        let camera = try Self.buildCamera()
        validateModeCondition(
            request: try camera.setWhiteBalanceTemp(.random),
            errorPrecondition: try camera.setWhiteBalance(.auto),
            successPrecondition: try camera.setWhiteBalance(.manual)
        )
        
        try camera.setWhiteBalance(.manual)
        validateStateRW(PTZWhiteBalanceTempState.self, values: PTZWhiteBalanceTemp.allCases, on: camera)
        validateMessageBytes(PTZWhiteBalanceTempState(.mid), "83 43 41 7F")
    }
    
    func testWhiteBalanceTintRequests() throws {
        let camera = try Self.buildCamera()
        validateModeCondition(
            request: try camera.setWhiteBalanceTint(.random),
            errorPrecondition: try camera.setWhiteBalance(.auto),
            successPrecondition: try camera.setWhiteBalance(.manual)
        )
        
        try camera.setWhiteBalance(.manual)
        validateStateRW(PTZWhiteBalanceTintState.self, values: PTZWhiteBalanceTint.allCases, on: camera)
        validateMessageBytes(PTZWhiteBalanceTintState(.mid), "83 43 40 7F")
    }
    
    func testWhiteLevelRequests() throws {
        let camera = try Self.buildCamera()
        validateStateRW(PTZWhiteLevelState.self, values: PTZWhiteLevel.allCases, on: camera)
        validateMessageBytes(PTZWhiteLevelState(.reduced), "83 43 3F 5A")
    }
}
