//
//  IrisLevel.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZIrisLevel: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 255
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZIrisLevel { .init(rawValue: 0) }
}

struct PTZIrisLevelState: PTZSingleValueState {
    static var name: String = "IrisLevel"
    static var register: (UInt8, UInt8) = (0x03, 0x00)
    
    var value: PTZIrisLevel
    
    init(_ value: PTZIrisLevel) {
        self.value = value
    }
    
    var modeConditionRescueRequests: [any PTZRequest] { [
        PTZAutoExposureState(.off).set(),
        PTZGainModeState(.gain0dB).set(),
        PTZBacklightCompensationState(.off).set()
    ] }
}
