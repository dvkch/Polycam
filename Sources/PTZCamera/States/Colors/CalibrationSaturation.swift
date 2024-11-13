//
//  CalibrationSaturation.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZCalibrationSaturation: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = Self.clamped(ptzValue) }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x76
    public static let ptzMax: UInt16 = 0x8A
    public static let unit: String = ""
    public static let `default`: Self = .mid
}

/// Controls the saturation for 6 distinct color ranges
/// Discovered by fuzzing
public struct PTZCalibrationSaturationState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "CalibrationSaturation"
    public static let register: PTZRegister<PTZCalibrationRange> = .init(0x03, 0x5C)
    public var variant: PTZCalibrationRange
    public var value: PTZCalibrationSaturation
    
    public init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
}
