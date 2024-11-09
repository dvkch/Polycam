//
//  CalibrationMatrix.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

/// Controls the hue, luminance and saturation for 6 distinct color ranges
/// Discovered by fuzzing
public struct PTZCalibrationMatrix: Equatable, CustomStringConvertible, CLIDecodable, JSONEncodable {
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
        let hue         = PTZCalibrationRange.allCases.map { self[hue: $0].description }.joined(separator: ", ")
        let luminance   = PTZCalibrationRange.allCases.map { self[luminance: $0].description }.joined(separator: ", ")
        let saturation  = PTZCalibrationRange.allCases.map { self[saturation: $0].description }.joined(separator: ", ")
        return "Hue(\(hue)), Luminance(\(luminance)), Saturation(\(saturation))"
    }
    
    public init?(from cliString: String) {
        let kinds = cliString.split(separator: "|")
        guard kinds.count == 3 else { return nil }
        
        let hues        = kinds[0].split(separator: ",").compactMap({ PTZCalibrationHue(from: String($0)) })
        let luminances  = kinds[1].split(separator: ",").compactMap({ PTZCalibrationLuminance(from: String($0)) })
        let saturations = kinds[2].split(separator: ",").compactMap({ PTZCalibrationSaturation(from: String($0)) })
        guard hues.count == 6, luminances.count == 6, saturations.count == 6 else { return nil }
        
        for (i, range) in PTZCalibrationRange.allCases.enumerated() {
            self[hue: range]        = hues[i]
            self[luminance: range]  = luminances[i]
            self[saturation: range] = saturations[i]
        }
    }
    
    public static var cliStringExamples: [String] {
        return ["h,h,h,h,h,h|l,l,l,l,l,l|s,s,s,s,s,s"]
    }
    
    public var toJSON: JSONValue {
        let hues        = PTZCalibrationRange.allCases.map({ self[hue: $0].toJSON })
        let luminances  = PTZCalibrationRange.allCases.map({ self[luminance: $0].toJSON })
        let saturations = PTZCalibrationRange.allCases.map({ self[saturation: $0].toJSON })
        return ["hues": hues, "luminances": luminances, "saturations": saturations]
    }
}

public struct PTZCalibrationMatrixState: PTZReadableCombo, PTZWriteableCombo {
    public static let name: String = "CalibrationMatrix"
    
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
