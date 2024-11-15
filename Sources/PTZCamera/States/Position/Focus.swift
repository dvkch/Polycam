//
//  Focus.swift
//  PTZ
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZFocus: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = Self.clamped(ptzValue) }
    public static let minValue: Int = 0
    public static let maxValue: Int = 500
    public static let ptzMin: UInt16 = 0xF0
    public static let ptzMax: UInt16 = 0x300
    public static let unit: String = ""
}

/// Controls the focus position. This is only possible when `PTZAutoFocusState` is `off`
/// Discovered by fuzzing
public struct PTZFocusState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "Focus"
    public static let register: PTZRegister<PTZNone> = .init(0x03, 0x03)

    public var value: PTZFocus
    
    public init(_ value: PTZFocus, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        return .init(
            name: "Set \(description)", message: setMessage(),
            modeConditionRescueRequests: [PTZAutoFocusState(.off).set()]
        )
    }
}
