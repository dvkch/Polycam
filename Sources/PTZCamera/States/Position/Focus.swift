//
//  Focus.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZFocus: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 240
    public static var maxValue: Int = 768 // max bytes are 06 00
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1
}

/// Controls the focus position. This is only possible when `PTZAutoFocusState` is `off`
/// Discovered by fuzzing
public struct PTZFocusState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "Focus"
    public static var register: (UInt8, UInt8) = (0x03, 0x03)

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
