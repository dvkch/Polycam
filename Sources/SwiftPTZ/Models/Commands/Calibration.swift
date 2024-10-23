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

struct PTZRequestSetCalibrationHue: PTZRequest {
    let range: PTZCalibrationRange
    let hue: PTZCalibrationHue
    var bytes: Bytes { buildBytes([0x43, 0x50 + UInt8(range.rawValue)], hue) }
    var description: String { "Calibrate \(range) hue to \(hue)" }
}

struct PTZRequestGetCalibrationHue: PTZGetRequest {
    typealias Reply = PTZReplyCalibrationHue
    let range: PTZCalibrationRange
    var bytes: Bytes { buildBytes([0x03, 0x50 + UInt8(range.rawValue)]) }
    var description: String { "Get \(range) calibration hue" }
}

struct PTZReplyCalibrationHue: PTZReply {
    let range: PTZCalibrationRange
    let hue: PTZCalibrationHue
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply([0x43, 0x50 + UInt8($0.rawValue)]) }) else { return nil }
        self.range = range
        self.hue = message.parseArgument(position: .single)
    }
    var description: String { "CalibrationHue(\(range), \(hue))" }
}

struct PTZRequestSetCalibrationLuminance: PTZRequest {
    let range: PTZCalibrationRange
    let luminance: PTZCalibrationLuminance
    var bytes: Bytes { buildBytes([0x43, 0x56 + UInt8(range.rawValue)], luminance) }
    var description: String { "Calibrate \(range) luminance to \(luminance)" }
}

struct PTZRequestGetCalibrationLuminance: PTZGetRequest {
    typealias Reply = PTZReplyCalibrationLuminance
    let range: PTZCalibrationRange
    var bytes: Bytes { buildBytes([0x03, 0x56 + UInt8(range.rawValue)]) }
    var description: String { "Get \(range) calibration luminance" }
}

struct PTZReplyCalibrationLuminance: PTZReply {
    let range: PTZCalibrationRange
    let luminance: PTZCalibrationLuminance
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply([0x43, 0x56 + UInt8($0.rawValue)]) }) else { return nil }
        self.range = range
        self.luminance = message.parseArgument(position: .single)
    }
    var description: String { "CalibrationLuminance(\(range), \(luminance))" }
}

struct PTZRequestSetCalibrationSaturation: PTZRequest {
    let range: PTZCalibrationRange
    let saturation: PTZCalibrationSaturation
    var bytes: Bytes { buildBytes([0x43, 0x5C + UInt8(range.rawValue)], saturation) }
    var description: String { "Calibrate \(range) saturation to \(saturation)" }
}

struct PTZRequestGetCalibrationSaturation: PTZGetRequest {
    typealias Reply = PTZReplyCalibrationSaturation
    let range: PTZCalibrationRange
    var bytes: Bytes { buildBytes([0x03, 0x5C + UInt8(range.rawValue)]) }
    var description: String { "Get \(range) calibration saturation" }
}

struct PTZReplyCalibrationSaturation: PTZReply {
    let range: PTZCalibrationRange
    let saturation: PTZCalibrationSaturation
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply([0x43, 0x5C + UInt8($0.rawValue)]) }) else { return nil }
        self.range = range
        self.saturation = message.parseArgument(position: .single)
    }
    var description: String { "CalibrationSaturation(\(range), \(saturation))" }
}
