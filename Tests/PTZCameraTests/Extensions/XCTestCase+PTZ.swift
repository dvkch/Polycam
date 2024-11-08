//
//  XCTestCase+PTZ.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import XCTest
import PTZMessaging
@testable import PTZCamera

extension XCTestCase {
    func validateStateRO<T: PTZReadable>(_ type: T.Type, expected: T.Value?, on camera: Camera) where T.Variant == PTZNone {
        validateStateRO(type, variants: PTZNone.allCases, expected: expected, on: camera)
    }
    
    func validateStateRO<T: PTZReadable>(_ type: T.Type, variants: [T.Variant], expected: T.Value?, on camera: Camera) {
        for variant in variants {
            XCTAssertNoThrow(try camera.get(type, for: variant))
            if let expected {
                XCTAssertEqual(try camera.get(type, for: variant), expected)
            }
        }
    }
}
    
extension XCTestCase {
    func validateStateWO<T: PTZWritable>(_ type: T.Type, values: [T.Value], on camera: Camera, sleep: TimeInterval = 0) where T.Variant == PTZNone {
        validateStateWO(type, variants: PTZNone.allCases, values: values, on: camera, sleep: sleep)
    }

    func validateStateWO<T: PTZWritable>(_ type: T.Type, variants: [T.Variant], values: [T.Value], on camera: Camera, sleep: TimeInterval = 0) {
        for variant in variants {
            for value in values {
                XCTAssertNoThrow(try camera.set(type.init(value, for: variant)))
                Thread.sleep(forTimeInterval: sleep)
            }
        }
    }
}
    
extension XCTestCase {
    func validateStateRW<T: PTZReadable & PTZWritable>(_ type: T.Type, values: [T.Value], on camera: Camera, sleep: TimeInterval = 0) where T.Variant == PTZNone {
        validateStateRW(type, variants: PTZNone.allCases, values: values, on: camera, sleep: sleep)
    }
    
    func validateStateRW<T: PTZReadable & PTZWritable>(_ type: T.Type, variants: [T.Variant], values: [T.Value], on camera: Camera, sleep: TimeInterval = 0) {
        for variant in variants {
            for value in values {
                XCTAssertNoThrow({
                    try camera.set(type.init(value, for: variant))
                    let reply = try camera.get(type, for: variant)
                    XCTAssertEqual(value, reply)
                })
                Thread.sleep(forTimeInterval: sleep)
            }
        }
    }
    
    func validateStateRW<T: PTZReadableCombo & PTZWriteableCombo>(_ type: T.Type, values: [T.Value], on camera: Camera, sleep: TimeInterval = 0) {
        for value in values {
            XCTAssertNoThrow({
                try camera.set(type.init(value))
                let reply = try camera.get(type)
                XCTAssertEqual(value, reply)
                Thread.sleep(forTimeInterval: sleep)
            })
        }
    }
}
    
extension XCTestCase {
    func validateModeCondition(
        request:             @autoclosure () throws(CameraError) -> (),
        errorPrecondition:   @autoclosure () throws(CameraError) -> (),
        successPrecondition: @autoclosure () throws(CameraError) -> (),
        sleep: TimeInterval = 0.1
    )
    {
        XCTAssertNoThrow(try errorPrecondition())
        Thread.sleep(forTimeInterval: sleep)
        XCTAssertThrowsError(try request()) { anyError in
            guard let error = anyError as? CameraError, case .notExecuted(.modeCondition, _) = error else {
                XCTFail("Unexpected error: \(anyError)")
                return
            }
        }

        XCTAssertNoThrow(try successPrecondition())
        Thread.sleep(forTimeInterval: sleep)
        XCTAssertNoThrow(try request())
    }
}
    
extension XCTestCase {
    func validateMessageBytes<T: PTZWritable>(_ state: T, _ hex: String) {
        XCTAssertEqual(state.setMessage().bytes.hexString, hex)
    }
}
