//
//  SleepTimeout.swift
//  PTZ
//
//  Created by syan on 29/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZSleepTimeout: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 1440 // 0x30 * 30min
    public static let ptzMin: UInt16 = 0x00
    public static let ptzMax: UInt16 = 0x30
    public static let unit: String = "min"
    public static let `default`: Self = .min
    
    public var description: String {
        guard rawValue > 0 else { return "off" }
        return String(rawValue) + "min"
    }
}

/// Sets a timeout for the device, after which it will turn off
/// Discovered by fuzzing
///
/// Unfortunately there doesn't seem to be a way to determine how long is remaining in the timeout. Setting one of the clocks could be a workaround
public struct PTZSleepTimeoutState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "SleepTimeout"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x01)

    public var value: PTZSleepTimeout
    
    public init(_ value: PTZSleepTimeout, for variant: PTZNone) {
        self.value = value
    }
}
