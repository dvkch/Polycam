//
//  IrisLevel.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZIrisLevel: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 255
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1
}

/// Controls the aperture. This is only possible when auto exposure is `off`, gain mode is not `auto` and backlight compensation is `off`
/// Discovered in the original program, extended by fuzzing
public struct PTZIrisLevelState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "IrisLevel"
    public static var register: (UInt8, UInt8) = (0x03, 0x00)
    
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
