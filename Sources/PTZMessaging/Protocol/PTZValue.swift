//
//  PTZValue.swift
//
//
//  Created by syan on 25/06/2024.
//

import Foundation
import CoreMedia

public protocol PTZValue: RawRepresentable, CustomStringConvertible, Equatable, CLIDecodable, Encodable where RawValue: Equatable {
    init(ptzValue: UInt16)
    var ptzValue: UInt16 { get }

    static var testValues: [Self] { get }
}

extension PTZValue {
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension PTZValue {
    internal init(from bytes: Bytes, loIndex: Int, hiIndex: Int, loRetainerIndex: Int, loRetainerMask: Byte) {
        assert(loIndex < bytes.count)
        assert(loRetainerIndex < bytes.count)
        assert(hiIndex < bytes.count)
        
        let hi = bytes[hiIndex]
        var lo = bytes[loIndex]
        let lowRetainer = (bytes[loRetainerIndex] & loRetainerMask) > 0
        if lowRetainer {
            lo += 128
        }
        
        self.init(ptzValue: UInt16(hi) << 8 + UInt16(lo))
    }

    internal var ptzBytes: (lo: Byte, loRetainer: Bool, hi: Byte) {
        let ptzValue = self.ptzValue

        var lo = Byte(ptzValue & 0xFF)
        var loRetainer = false
        if lo >= 128 {
            lo -= 128
            loRetainer = true
        }
        let hi = Byte((ptzValue >> 8) & 0xFF)
        return (lo, loRetainer, hi)
    }
}

public struct PTZUInt: PTZValue {
    public let rawValue: UInt16

    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    public init(ptzValue: UInt16) {
        self.rawValue = ptzValue
    }
    
    public var ptzValue: UInt16 {
        return rawValue
    }
    
    public static var testValues: [PTZUInt] { [.init(rawValue: 0)] }
    
    public var description: String {
        return String(rawValue)
    }
    
    public init?(from cliString: String) {
        guard let value = UInt16(cliString) else { return nil }
        self.rawValue = value
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

public struct PTZBool: PTZValue {
    public let rawValue: Bool
    
    public init(rawValue: Bool) {
        self.rawValue = rawValue
    }
    
    public init(ptzValue: UInt16) {
        self.rawValue = ptzValue > 0
    }
    
    public var ptzValue: UInt16 {
        return rawValue ? 0x01 : 0x00
    }
    
    public static var testValues: [PTZBool] { [.init(rawValue: true), .init(rawValue: false)] }
    
    public static var on: PTZBool { .init(rawValue: true) }
    public static var off: PTZBool { .init(rawValue: false) }
    
    public var description: String {
        return rawValue ? "on" : "off"
    }
    
    public init?(from cliString: String) {
        if cliString == "true" || cliString == "1" {
            self.rawValue = true
        }
        else if cliString == "false" || cliString == "0" {
            self.rawValue = false
        }
        else {
            return nil
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension PTZValue where Self: CaseIterable, Self: RawRepresentable, RawValue == UInt16 {
    public init(ptzValue: UInt16) {
        self = Self.allCases.first(where: { $0.ptzValue == ptzValue })!
    }
    
    public var ptzValue: UInt16 {
        return UInt16(rawValue)
    }
    
    public init?(from cliString: String) {
        if let item = Self.allCases.first(where: { $0.description.lowercased() == cliString.lowercased() }) {
            self = item
        }
        else if let value = UInt16(cliString) {
            self.init(rawValue: value)
        }
        else {
            return nil
        }
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension RawRepresentable where Self: CaseIterable {
    public static var testValues: [Self] { Array(allCases) }
}

#warning("add Unit property, use it in description, rewite scales for most of defined scaled values to use it properly")
#warning("redefine")
// min/max should be minimum/maximum values supported over the wire
// and it should be able to init it using a percentage to get the corresponding wire value
public protocol PTZScaledValue: PTZValue where RawValue == Int {
    var rawValue: Int { get set }
    static var minValue: Int { get }
    static var maxValue: Int { get }
    static var ptzOffset: Int { get }
    static var ptzScale: Double { get }
}

extension PTZScaledValue {
    public init(ptzValue: UInt16) {
        let value = Double(Int(ptzValue) - Self.ptzOffset) / Self.ptzScale
        self.init(rawValue: Int(value))!
    }
    
    public var ptzValue: UInt16 {
        let value = Int(Double(clamped) * Self.ptzScale) + Self.ptzOffset
        return UInt16(value)
    }
    
    public static var testValues: [Self] {
        var allValues = Array(minValue...maxValue)
        if allValues.count > 100 {
            allValues = stride(from: minValue, to: maxValue, by: allValues.count / 100) + [maxValue]
        }
        return allValues.map { Self.init(rawValue: $0)! }
    }
    
    public static var min: Self {
        return Self.init(rawValue: minValue)!
    }
    
    public static var mid: Self {
        return Self.init(rawValue: (maxValue - minValue) / 2 + minValue)!
    }
    
    public static var max: Self {
        return Self.init(rawValue: maxValue)!
    }
    
    public static var random: Self {
        return Self.init(rawValue: (minValue...maxValue).randomElement()!)!
    }
    
    public var description: String {
        return String(rawValue)
    }
    
    public init?(from cliString: String) {
        guard let rawValue = Int(cliString) else { return nil }
        self.init(rawValue: rawValue)
    }
    
    public func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension PTZScaledValue {
    var isValid: Bool {
        return rawValue >= type(of: self).minValue && rawValue <= type(of: self).maxValue
    }
    
    var clamped: RawValue {
        return Swift.min(type(of: self).maxValue, Swift.max(type(of: self).minValue, rawValue))
    }
}
