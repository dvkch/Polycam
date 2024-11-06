//
//  CalibrationMatrix.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZCalibrationMatrix: Equatable, CustomStringConvertible, Codable {
    internal var hue:         [PTZCalibrationRange: PTZCalibrationHue] = [:]
    internal var luminance:   [PTZCalibrationRange: PTZCalibrationLuminance] = [:]
    internal var saturation:  [PTZCalibrationRange: PTZCalibrationSaturation] = [:]
    
    public init() {}
    
    public subscript(hue range: PTZCalibrationRange) -> PTZCalibrationHue {
        get { hue[range, default: .default] }
        set { hue[range] = newValue }
    }
    
    public subscript(luminance range: PTZCalibrationRange) -> PTZCalibrationLuminance {
        get { luminance[range, default: .default] }
        set { luminance[range] = newValue }
    }
    
    public subscript(saturation range: PTZCalibrationRange) -> PTZCalibrationSaturation {
        get { saturation[range, default: .default] }
        set { saturation[range] = newValue }
    }
    
    public var description: String {
        let hue = PTZCalibrationRange.allCases.map { self[hue: $0].description }.joined(separator: ", ")
        let luminance = PTZCalibrationRange.allCases.map { self[hue: $0].description }.joined(separator: ", ")
        let saturation = PTZCalibrationRange.allCases.map { self[hue: $0].description }.joined(separator: ", ")
        return "Hue(\(hue)), Luminance(\(luminance)), Saturation(\(saturation))"
    }
    
    private enum CodingKeys: String, CodingKey {
        case hue = "hue"
        case luminance = "luminance"
        case saturation = "saturation"
    }
    
    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let hue = try container.decode([PTZCalibrationHue].self, forKey: .hue)
        let luminance = try container.decode([PTZCalibrationLuminance].self, forKey: .luminance)
        let saturation = try container.decode([PTZCalibrationSaturation].self, forKey: .saturation)
        
        for (i, range) in PTZCalibrationRange.allCases.enumerated() {
            self[hue: range] = hue.element(at: i) ?? .default
            self[luminance: range] = luminance.element(at: i) ?? .default
            self[saturation: range] = saturation.element(at: i) ?? .default
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(PTZCalibrationRange.allCases.map({ self[hue: $0] }), forKey: .hue)
        try container.encode(PTZCalibrationRange.allCases.map({ self[luminance: $0] }), forKey: .luminance)
        try container.encode(PTZCalibrationRange.allCases.map({ self[saturation: $0] }), forKey: .saturation)
    }
}

public struct PTZCalibrationMatrixState: PTZReadableCombo, PTZWriteableCombo {
    public static var name: String = "CalibrationMatrix"
    
    public let variant = PTZNone()
    public var value: PTZCalibrationMatrix
    
    public init(_ value: PTZCalibrationMatrix) {
        self.value = value
    }

    public init?(messages: [PTZMessage]) {
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

    public func set() -> [PTZRequest] {
        return PTZCalibrationRange.allCases.map({[
            PTZCalibrationHueState(value[hue: $0], for: $0).set(),
            PTZCalibrationLuminanceState(value[luminance: $0], for: $0).set(),
            PTZCalibrationSaturationState(value[saturation: $0], for: $0).set(),
        ]}).reduce([], +)
    }
    
    public static func get() -> [PTZRequest] {
        return PTZCalibrationRange.allCases.map({[
            PTZCalibrationHueState.get(for: $0),
            PTZCalibrationLuminanceState.get(for: $0),
            PTZCalibrationSaturationState.get(for: $0),
        ]}).reduce([], +)
    }
}
