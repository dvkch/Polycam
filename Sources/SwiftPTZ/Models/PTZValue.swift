//
//  PTZValue.swift
//
//
//  Created by syan on 25/06/2024.
//

import Foundation
import CoreMedia

protocol PTZValue: RawRepresentable, CustomStringConvertible, Equatable where RawValue: Equatable {
    init(ptzValue: UInt16)
    var ptzValue: UInt16 { get }

    static var `default`: Self { get }
    static var testValues: [Self] { get }
}

extension PTZValue {
    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}

extension PTZValue {
    init(from bytes: Bytes, loIndex: Int, hiIndex: Int, loRetainerIndex: Int, loRetainerMask: Byte) {
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

    var ptzBytes: (lo: Byte, loRetainer: Bool, hi: Byte) {
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

struct PTZUInt: PTZValue {
    let rawValue: UInt16

    init(rawValue: UInt16) {
        self.rawValue = rawValue
    }

    init(ptzValue: UInt16) {
        self.rawValue = UInt16(ptzValue)
    }
    
    var ptzValue: UInt16 {
        return UInt16(rawValue)
    }
    
    static var testValues: [PTZUInt] { [.init(rawValue: 0)] }
    static var `default`: PTZUInt { .init(rawValue: 0) }
    
    var description: String {
        return String(rawValue)
    }
}

struct PTZBool: PTZValue {
    let rawValue: Bool

    init(rawValue: Bool) {
        self.rawValue = rawValue
    }

    init(ptzValue: UInt16) {
        self.rawValue = ptzValue > 0
    }
    
    var ptzValue: UInt16 {
        return rawValue ? 0x01 : 0x00
    }
    
    static var testValues: [PTZBool] { [.init(rawValue: true), .init(rawValue: false)] }
    static var `default`: PTZBool { .init(rawValue: false) }
    
    static var on: PTZBool { .init(rawValue: true) }
    static var off: PTZBool { .init(rawValue: false) }
    
    var description: String {
        return rawValue ? "on" : "off"
    }
}

extension RawRepresentable where Self: CaseIterable, RawValue == UInt16 {
    init(ptzValue: UInt16) {
        self = Self.allCases.first(where: { $0.ptzValue == ptzValue })!
    }
    
    var ptzValue: UInt16 {
        return UInt16(rawValue)
    }
}

extension RawRepresentable where Self: CaseIterable {
    static var testValues: [Self] { Array(allCases) }
}

#warning("add Unit property, use it in description, rewite scales for most of defined scaled values to use it properly")
#warning("redefine")
// min/max should be minimum/maximum values supported over the wire
// and it should be able to init it using a percentage to get the corresponding wire value
protocol PTZScaledValue: PTZValue where RawValue == Int {
    var rawValue: Int { get set }
    static var minValue: Int { get }
    static var maxValue: Int { get }
    static var ptzOffset: Int { get }
    static var ptzScale: Double { get }
}

extension PTZScaledValue {
    init(ptzValue: UInt16) {
        let value = Double(Int(ptzValue) - Self.ptzOffset) / Self.ptzScale
        self.init(rawValue: Int(value))!
    }
    
    var ptzValue: UInt16 {
        let value = Int(Double(clamped) * Self.ptzScale) + Self.ptzOffset
        return UInt16(value)
    }
    
    static var testValues: [Self] {
        var allValues = Array(minValue...maxValue)
        if allValues.count > 100 {
            allValues = stride(from: minValue, to: maxValue, by: allValues.count / 100) + [maxValue]
        }
        return allValues.map { Self.init(rawValue: $0)! }
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
    
    var description: String {
        return String(rawValue)
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
