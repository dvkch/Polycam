//
//  ColorGain.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZColorGain: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x60
    public static let ptzMax: UInt16 = 0x9F
    public static let unit: String = "%"
    public static let `default`: Self = .init(ptzValue: 0x82) // original system uses 0x84 for red, 0x80 for blue
}

public enum PTZColorGainChannel: UInt8, PTZVariant {
    case red  = 0
    case blue = 1
    
    public var description: String {
        switch self {
        case .red:  return "red"
        case .blue: return "blue"
        }
    }
}

/// Controls the blue channel gain, depends on the configured whitebalance
/// Discovered in the original application's logs
public struct PTZColorGainState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "ColorGain"
    public static let register: PTZRegister<PTZColorGainChannel> = .init(0x03, 0x42)
    public var variant: PTZColorGainChannel
    public var value: PTZColorGain
    
    public init(_ value: PTZColorGain, for variant: PTZColorGainChannel) {
        self.variant = variant
        self.value = value
    }
}
