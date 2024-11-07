//
//  CalibrationSaturation.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZCalibrationSaturation: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int { 0x76 }
    public static var maxValue: Int { 0x8A }
    public static var ptzOffset: Int { 0 }
    public static var ptzScale: Double { 1 }
    public static var `default`: PTZCalibrationSaturation { .init(rawValue: 0x80) }
}

/// Controls the saturation for 6 distinct color ranges
/// Discovered by fuzzing
public struct PTZCalibrationSaturationState: PTZReadable, PTZWriteable {
    public static var name: String = "CalibrationSaturation"
    
    public var variant: PTZCalibrationRange
    public var value: PTZCalibrationSaturation
    
    public init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    public init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply((0x43, 0x5C + UInt8($0.rawValue))) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    public func setMessage() -> PTZMessage {
        return .init((0x03, 0x5C + UInt8(variant.rawValue)))
    }
    
    public static func get(for variant: PTZCalibrationRange) -> PTZRequest {
        return .init(name: name, message: .init((0x03, 0x5C + UInt8(variant.rawValue))))
    }
}
