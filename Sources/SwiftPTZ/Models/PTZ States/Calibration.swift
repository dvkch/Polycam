//
//  Calibration.swift
//  SwiftPTZ
//
//  Created by syan on 23/10/2024.
//

#warning("make use of this")
typealias PTZCalibrationMatrix = [PTZCalibrationRange: (PTZCalibrationHue, PTZCalibrationLuminance, PTZCalibrationSaturation)]

struct PTZCalibrationHue: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int { 0x7B }
    static var maxValue: Int { 0x85 }
    static var ptzOffset: Int { 0 }
    static var ptzScale: Double { 1 }
    static var `default`: PTZCalibrationHue { .init(rawValue: 0x80) }
}

struct PTZCalibrationLuminance: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int { 0x76 }
    static var maxValue: Int { 0x8A }
    static var ptzOffset: Int { 0 }
    static var ptzScale: Double { 1 }
    static var `default`: PTZCalibrationLuminance { .init(rawValue: 0x80) }
}

struct PTZCalibrationSaturation: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int { 0x76 }
    static var maxValue: Int { 0x8A }
    static var ptzOffset: Int { 0 }
    static var ptzScale: Double { 1 }
    static var `default`: PTZCalibrationSaturation { .init(rawValue: 0x80) }
}

enum PTZCalibrationRange: UInt16, CaseIterable, PTZValue {
    case red = 0x00
    case orange = 0x01
    case green = 0x02
    case cyan = 0x03
    case blue = 0x04
    case purple = 0x05
    static var `default`: PTZCalibrationRange { .red }
    
    var description: String {
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

struct PTZCalibrationHueState: PTZState {
    static var name: String = "CalibrationHue"
    
    var variant: PTZCalibrationRange
    var value: PTZCalibrationHue
    
    init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply([0x43, 0x50 + UInt8($0.rawValue)]) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    func set() -> any PTZRequest {
        return PTZStateRequest(name: "Set \(description)", message: .init([0x03, 0x50 + UInt8(variant.rawValue)]))
    }
    
    static func get(for variant: PTZCalibrationRange) -> any PTZRequest {
        return PTZStateRequest(name: name, message: .init([0x03, 0x50 + UInt8(variant.rawValue)]))
    }
}

struct PTZCalibrationLuminanceState: PTZState {
    static var name: String = "CalibrationLuminance"
    
    var variant: PTZCalibrationRange
    var value: PTZCalibrationLuminance
    
    init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply([0x43, 0x56 + UInt8($0.rawValue)]) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    func set() -> any PTZRequest {
        return PTZStateRequest(name: "Set \(description)", message: .init([0x03, 0x56 + UInt8(variant.rawValue)]))
    }
    
    static func get(for variant: PTZCalibrationRange) -> any PTZRequest {
        return PTZStateRequest(name: name, message: .init([0x03, 0x56 + UInt8(variant.rawValue)]))
    }
}

struct PTZCalibrationSaturationState: PTZState {
    static var name: String = "CalibrationSaturation"
    
    var variant: PTZCalibrationRange
    var value: PTZCalibrationSaturation
    
    init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply([0x43, 0x5C + UInt8($0.rawValue)]) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    func set() -> any PTZRequest {
        return PTZStateRequest(name: "Set \(description)", message: .init([0x03, 0x5C + UInt8(variant.rawValue)]))
    }
    
    static func get(for variant: PTZCalibrationRange) -> any PTZRequest {
        return PTZStateRequest(name: name, message: .init([0x03, 0x5C + UInt8(variant.rawValue)]))
    }
}
