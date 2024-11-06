//
//  Calibration.swift
//  SwiftPTZ
//
//  Created by syan on 23/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZCalibrationMatrix: Equatable, CustomStringConvertible {
    internal var hue:         [PTZCalibrationRange: PTZCalibrationHue] = [:]
    internal var luminance:   [PTZCalibrationRange: PTZCalibrationLuminance] = [:]
    internal var saturation:  [PTZCalibrationRange: PTZCalibrationSaturation] = [:]
    
    subscript(hue range: PTZCalibrationRange) -> PTZCalibrationHue {
        get { hue[range, default: .default] }
        set { hue[range] = newValue }
    }
    
    subscript(luminance range: PTZCalibrationRange) -> PTZCalibrationLuminance {
        get { luminance[range, default: .default] }
        set { luminance[range] = newValue }
    }
    
    subscript(saturation range: PTZCalibrationRange) -> PTZCalibrationSaturation {
        get { saturation[range, default: .default] }
        set { saturation[range] = newValue }
    }
    
    public var description: String {
        let hue = PTZCalibrationRange.allCases.map { self[hue: $0].description }.joined(separator: ", ")
        let luminance = PTZCalibrationRange.allCases.map { self[hue: $0].description }.joined(separator: ", ")
        let saturation = PTZCalibrationRange.allCases.map { self[hue: $0].description }.joined(separator: ", ")
        return "Hue(\(hue)), Luminance(\(luminance)), Saturation(\(saturation))"
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

public struct PTZCalibrationLuminance: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int { 0x76 }
    public static var maxValue: Int { 0x8A }
    public static var ptzOffset: Int { 0 }
    public static var ptzScale: Double { 1 }
    public static var `default`: PTZCalibrationLuminance { .init(rawValue: 0x80) }
}

public struct PTZCalibrationSaturation: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int { 0x76 }
    public static var maxValue: Int { 0x8A }
    public static var ptzOffset: Int { 0 }
    public static var ptzScale: Double { 1 }
    public static var `default`: PTZCalibrationSaturation { .init(rawValue: 0x80) }
}

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

internal struct PTZCalibrationHueState: PTZReadable, PTZWriteable {
    static var name: String = "CalibrationHue"
    
    var variant: PTZCalibrationRange
    var value: PTZCalibrationHue
    
    init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    #warning("use a specific struct type for Registers, allowing them to handle variants (using a case iterable enum and an offset)")
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply((0x43, 0x50 + UInt8($0.rawValue))) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    func setMessage() -> PTZMessage {
        return .init((0x03, 0x50 + UInt8(variant.rawValue)))
    }
    
    static func get(for variant: PTZCalibrationRange) -> PTZRequest {
        return .init(name: name, message: .init((0x03, 0x50 + UInt8(variant.rawValue))))
    }
}

internal struct PTZCalibrationLuminanceState: PTZReadable, PTZWriteable {
    static var name: String = "CalibrationLuminance"
    
    var variant: PTZCalibrationRange
    var value: PTZCalibrationLuminance
    
    init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply((0x43, 0x56 + UInt8($0.rawValue))) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    func setMessage() -> PTZMessage {
        return .init((0x03, 0x56 + UInt8(variant.rawValue)))
    }
    
    static func get(for variant: PTZCalibrationRange) -> PTZRequest {
        return .init(name: name, message: .init((0x03, 0x56 + UInt8(variant.rawValue))))
    }
}

internal struct PTZCalibrationSaturationState: PTZReadable, PTZWriteable {
    static var name: String = "CalibrationSaturation"
    
    var variant: PTZCalibrationRange
    var value: PTZCalibrationSaturation
    
    init(_ value: Value, for variant: Variant) {
        self.value = value
        self.variant = variant
    }
    
    init?(message: PTZMessage) {
        guard let range = PTZCalibrationRange.allCases.first(where: { message.isValidReply((0x43, 0x5C + UInt8($0.rawValue))) }) else { return nil }
        self.variant = range
        self.value = message.parseArgument(position: .single)
    }
    
    func setMessage() -> PTZMessage {
        return .init((0x03, 0x5C + UInt8(variant.rawValue)))
    }
    
    static func get(for variant: PTZCalibrationRange) -> PTZRequest {
        return .init(name: name, message: .init((0x03, 0x5C + UInt8(variant.rawValue))))
    }
}

internal struct PTZCalibrationMatrixState: PTZReadableCombo, PTZWriteableCombo {
    static var name: String = "CalibrationMatrix"
    
    let variant = PTZNone()
    var value: PTZCalibrationMatrix
    
    init(_ value: PTZCalibrationMatrix) {
        self.value = value
    }

    init?(messages: [PTZMessage]) {
        self.value = .init()
        for message in messages {
            if let hue = PTZCalibrationHueState(message: message) {
                self.value[hue: hue.variant] = hue.value
            }
            if let luminance = PTZCalibrationLuminanceState(message: message) {
                self.value[luminance: luminance.variant] = luminance.value
            }
            if let saturation = PTZCalibrationSaturationState(message: message) {
                self.value[saturation: saturation.variant] = saturation.value
            }
        }
        guard value.hue.count == 6, value.luminance.count == 6, value.saturation.count == 6 else { return nil }
    }

    func set() -> [PTZRequest] {
        return PTZCalibrationRange.allCases.map({[
            PTZCalibrationHueState(value[hue: $0], for: $0).set(),
            PTZCalibrationLuminanceState(value[luminance: $0], for: $0).set(),
            PTZCalibrationSaturationState(value[saturation: $0], for: $0).set(),
        ]}).reduce([], +)
    }
    
    static func get() -> [PTZRequest] {
        return PTZCalibrationRange.allCases.map({[
            PTZCalibrationHueState.get(for: $0),
            PTZCalibrationLuminanceState.get(for: $0),
            PTZCalibrationSaturationState.get(for: $0),
        ]}).reduce([], +)
    }
}
