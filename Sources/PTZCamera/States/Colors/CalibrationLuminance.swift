//
//  CalibrationLuminance.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZCalibrationLuminance: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x76
    public static let ptzMax: UInt16 = 0x8A
    public static let unit: String = ""
    public static let `default`: Self = .mid
}

/// Controls the luminance for 6 distinct color ranges
/// Discovered by fuzzing
public struct PTZCalibrationLuminanceState: PTZReadable, PTZWriteable {
    public static var name: String = "CalibrationLuminance"
    
    public var variant: PTZCalibrationRange
    public var value: PTZCalibrationLuminance
    
    public init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    public init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply((0x43, 0x56 + UInt8($0.rawValue))) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    public func setMessage() -> PTZMessage {
        return .init((0x03, 0x56 + UInt8(variant.rawValue)))
    }
    
    public static func get(for variant: PTZCalibrationRange) -> PTZRequest {
        return .init(name: name, message: .init((0x03, 0x56 + UInt8(variant.rawValue))))
    }
}
