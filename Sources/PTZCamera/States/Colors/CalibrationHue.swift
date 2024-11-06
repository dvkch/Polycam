//
//  CalibrationHue.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZCalibrationRange: UInt16, CaseIterable, PTZValue {
    case red = 0x00
    case orange = 0x01
    case green = 0x02
    case cyan = 0x03
    case blue = 0x04
    case purple = 0x05
    public static var `default`: PTZCalibrationRange { .red }
    
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
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int { 0x7B }
    public static var maxValue: Int { 0x85 }
    public static var ptzOffset: Int { 0 }
    public static var ptzScale: Double { 1 }
    public static var `default`: PTZCalibrationHue { .init(rawValue: 0x80) }
}

public struct PTZCalibrationHueState: PTZReadable, PTZWriteable {
    public static var name: String = "CalibrationHue"
    
    public var variant: PTZCalibrationRange
    public var value: PTZCalibrationHue
    
    public init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    #warning("use a specific struct type for Registers, allowing them to handle variants (using a case iterable enum and an offset)")
    public init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply((0x43, 0x50 + UInt8($0.rawValue))) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    public func setMessage() -> PTZMessage {
        return .init((0x03, 0x50 + UInt8(variant.rawValue)))
    }
    
    public static func get(for variant: PTZCalibrationRange) -> PTZRequest {
        return .init(name: name, message: .init((0x03, 0x50 + UInt8(variant.rawValue))))
    }
}
