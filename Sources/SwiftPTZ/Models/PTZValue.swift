//
//  PTZValue.swift
//
//
//  Created by syan on 25/06/2024.
//

import Foundation
import CoreMedia

protocol PTZValue: RawRepresentable, Equatable where RawValue: Equatable {
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

struct PTZInt: PTZValue {
    let rawValue: Int

    init(rawValue: Int) {
        self.rawValue = rawValue
    }

    init(ptzValue: UInt16) {
        self.rawValue = Int(ptzValue)
    }
    
    var ptzValue: UInt16 {
        return UInt16(rawValue)
    }
    
    static var testValues: [PTZInt] { [.init(rawValue: 0)] }
    static var `default`: PTZInt { .init(rawValue: 0) }
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
}

extension RawRepresentable where Self: CaseIterable, RawValue == UInt16 {
    init(ptzValue: UInt16) {
        self = Self.allCases.first(where: { $0.ptzValue == ptzValue })!
    }
    
    var ptzValue: UInt16 {
        return UInt16(rawValue)
    }
    
    static var testValues: [Self] { Array(allCases) }
}

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
}

extension PTZScaledValue {
    var isValid: Bool {
        return rawValue >= type(of: self).minValue && rawValue <= type(of: self).maxValue
    }
    
    var clamped: RawValue {
        return Swift.min(type(of: self).maxValue, Swift.max(type(of: self).minValue, rawValue))
    }
}
