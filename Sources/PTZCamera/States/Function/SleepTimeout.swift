//
//  SleepTimeout.swift
//  SwiftPTZ
//
//  Created by syan on 29/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZSleepTimeout: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 1440 // 0x30 * 30min
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1/30
    public static var `default`: Self { .init(rawValue: 0) }
    
    public var description: String {
        guard rawValue > 0 else { return "off" }
        return String(rawValue) + "min"
    }
}

internal struct PTZSleepTimeoutState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "SleepTimeout"
    static var register: (UInt8, UInt8) = (0x01, 0x01)

    var value: PTZSleepTimeout
    
    init(_ value: PTZSleepTimeout, for variant: PTZNone) {
        self.value = value
    }
}