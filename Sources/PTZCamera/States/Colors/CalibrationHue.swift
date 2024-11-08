//
//  CalibrationHue.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZCalibrationRange: UInt8, PTZVariant {
    case red = 0x00
    case orange = 0x01
    case green = 0x02
    case cyan = 0x03
    case blue = 0x04
    case purple = 0x05
    
    public var description: String {
        switch self {
        case .red:      return "red"
        case .orange:   return "orange"
        case .green:    return "green"
        case .cyan:     return "cyan"
        case .blue:     return "blue"
        case .purple:   return "purple"
        }
    }
}

public struct PTZCalibrationHue: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x7B
    public static let ptzMax: UInt16 = 0x85
    public static let unit: String = ""
    public static let `default`: Self = .mid
}

/// Controls the hue for 6 distinct color ranges
/// Discovered by fuzzing
public struct PTZCalibrationHueState: PTZParseableState, PTZReadable, PTZWritable {
    public static var name: String = "CalibrationHue"
    public static var register: PTZRegister<PTZCalibrationRange> = .init(0x03, 0x50)
    public var variant: PTZCalibrationRange
    public var value: PTZCalibrationHue
    
    public init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
}
