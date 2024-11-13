//
//  PTZScaledValue.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public protocol PTZScaledValue: PTZValue, ExpressibleByIntegerLiteral where RawValue == Int {
    var ptzValue: UInt16 { get set }
    init(ptzValue: UInt16)
    static var minValue: Int { get }
    static var maxValue: Int { get }
    static var ptzMin: UInt16 { get }
    static var ptzMax: UInt16 { get }
    static var unit: String { get }
}

extension PTZScaledValue {
    public static func clamped(_ ptzValue: UInt16) -> UInt16 {
        return Swift.min(ptzMax, Swift.max(ptzMin, ptzValue))
    }
}

extension PTZScaledValue {
    public init(integerLiteral value: Int) {
        self.init(rawValue: value)!
    }
    
    public var rawValue: Int {
        return Self.convert(fromPTZ: ptzValue)
    }
    
    public init(rawValue: RawValue) {
        self.init(ptzValue: Self.convert(fromValue: rawValue))
    }
}

private extension PTZScaledValue {
    static func convert(fromPTZ ptz: UInt16) -> Int {
        let clampedPtz = Swift.min(Self.ptzMax, Swift.max(Self.ptzMin, ptz))
        let percentage: Double = Double(clampedPtz - Self.ptzMin) / Double(Self.ptzMax - Self.ptzMin)
        return Self.minValue + Int((percentage * Double(Self.maxValue - Self.minValue)).rounded(.toNearestOrAwayFromZero))
    }
    static func convert(fromValue value: Int) -> UInt16 {
        let clampValue = Swift.min(Self.maxValue, Swift.max(Self.minValue, value))
        let percentage: Double = Double(clampValue - Self.minValue) / Double(Self.maxValue - Self.minValue)
        return Self.ptzMin + UInt16((percentage * Double(Self.ptzMax - Self.ptzMin)).rounded(.toNearestOrAwayFromZero))
    }
}

public extension PTZScaledValue {
    var isValid: Bool {
        return ptzValue >= type(of: self).ptzMin && ptzValue <= type(of: self).ptzMax
    }
    
    static var min: Self {
        return Self.init(ptzValue: ptzMin)
    }
    
    static var mid: Self {
        return Self.init(ptzValue: (ptzMax - ptzMin) / 2 + ptzMin)
    }
    
    static var max: Self {
        return Self.init(ptzValue: ptzMax)
    }
    
    static var random: Self {
        return Self.init(ptzValue: (ptzMin...ptzMax).randomElement()!)
    }
}

extension PTZScaledValue {
    public var ptzValue: UInt16 {
        return Self.convert(fromValue: rawValue)
    }
    
    public static var allCases: [Self] {
        let allValues = Array(ptzMin...ptzMax)
        return allValues.lazy.map { Self.init(ptzValue: $0) }
    }
    
    public var description: String {
        return String(rawValue) + Self.unit
    }
    
    public init?(from cliString: String) {
        guard let rawValue = Int(cliString) else { return nil }
        self.init(rawValue: rawValue)
    }
    
    public static var cliStringExamples: [String] {
        return [min.description + "->" + max.description]
    }
    
    public var toJSON: JSONValue {
        return rawValue
    }
}
