//
//  IrisLevel.swift
//  PTZ
//
//  Created by syan on 10/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZIrisLevel: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x00
    public static let ptzMax: UInt16 = 0xFF
    public static let unit: String = ""
}

/// Controls the aperture. This is only possible when auto exposure is `off`, gain mode is not `auto` and backlight compensation is `off`
/// Discovered in the original program, extended by fuzzing
public struct PTZIrisLevelState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "IrisLevel"
    public static let register: PTZRegister<PTZNone> = .init(0x03, 0x00)
    
    public var value: PTZIrisLevel
    
    public init(_ value: PTZIrisLevel, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), modeConditionRescueRequests: [
            PTZAutoExposureState(.off).set(),
            PTZGainModeState(.gain0dB).set(),
            PTZBacklightCompensationState(.off).set()
        ])
    }
}
