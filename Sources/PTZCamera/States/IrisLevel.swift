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

internal struct PTZIrisLevelState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "IrisLevel"
    static var register: (UInt8, UInt8) = (0x03, 0x00)
    
    var value: PTZIrisLevel
    
    init(_ value: PTZIrisLevel, for variant: PTZNone) {
        self.value = value
    }
    
#warning("look for all setRequest()")
    func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), modeConditionRescueRequests: [
            PTZAutoExposureState(.off).set(),
            PTZGainModeState(.gain0dB).set(),
            PTZBacklightCompensationState(.off).set()
        ])
    }
}
