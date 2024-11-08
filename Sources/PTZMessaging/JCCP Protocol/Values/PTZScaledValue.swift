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
        let percentage: Double = Double(ptz - Self.ptzMin) / Double(Self.ptzMax - Self.ptzMin)
        return Self.minValue + Int(round(percentage * Double(Self.maxValue - Self.minValue)))
    }
    static func convert(fromValue value: Int) -> UInt16 {
        let percentage: Double = Double(value - Self.minValue) / Double(Self.maxValue - Self.minValue)
        return Self.ptzMin + UInt16(round(percentage * Double(Self.ptzMax - Self.ptzMin)))
    }
}

public extension PTZScaledValue {
    var isValid: Bool {
        return rawValue >= type(of: self).minValue && rawValue <= type(of: self).maxValue
    }
    
    var clamped: RawValue {
        return Swift.min(type(of: self).maxValue, Swift.max(type(of: self).minValue, rawValue))
    }

    static var min: Self {
        return Self.init(rawValue: minValue)!
    }
    
    static var mid: Self {
        return Self.init(rawValue: (maxValue - minValue) / 2 + minValue)!
    }
    
    static var max: Self {
        return Self.init(rawValue: maxValue)!
    }
    
    static var random: Self {
        return Self.init(rawValue: (minValue...maxValue).randomElement()!)!
    }
}

extension PTZScaledValue {
    public init(ptzValue: UInt16) {
        self.init(rawValue: Self.convert(fromPTZ: ptzValue))!
    }
    
    public var ptzValue: UInt16 {
        return Self.convert(fromValue: rawValue)
    }
    
    public static var allCases: [Self] {
        let allValues = Array(minValue...maxValue)
        return allValues.lazy.map { Self.init(rawValue: $0)! }
    }
    
    public var description: String {
        return String(rawValue) + Self.unit
    }
    
    public init?(from cliString: String) {
        guard let rawValue = Int(cliString) else { return nil }
        self.init(rawValue: rawValue)
    }
    
    public var toJSON: JSONValue {
        return rawValue
    }
}
