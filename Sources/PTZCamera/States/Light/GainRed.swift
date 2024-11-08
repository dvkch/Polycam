//
//  GainRed.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZColorGain: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 100
    public static var ptzMin: UInt16 = 0x60
    public static var ptzMax: UInt16 = 0x9F
    public static var unit: String = "%"
    public static var `default`: Self = .init(ptzValue: 0x82) // original system uses 0x84 for red, 0x80 for blue
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
