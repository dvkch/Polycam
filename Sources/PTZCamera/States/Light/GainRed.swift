//
//  GainRed.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZColorGain: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 1
    public static var maxValue: Int = 64
    public static var ptzOffset: Int = 95 // 33 should be 01 00, 37 should be 01 04
    public static var ptzScale: Double = 1
    public static var `default`: PTZColorGain { .init(rawValue: 35) } // original system uses 37 for red, 33 for blue
}

/// Controls the red channel gain, depends on the configured whitebalance
/// Discovered in the original application's logs
public struct PTZGainRedState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "GainRed"
    public static var register: (UInt8, UInt8) = (0x03, 0x42)
    
    public var value: PTZColorGain
    
    public init(_ value: PTZColorGain, for variant: PTZNone) {
        self.value = value
    }
}
