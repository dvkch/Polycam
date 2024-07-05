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
}

extension RawRepresentable where Self: CaseIterable, RawValue == UInt16 {
    init(ptzValue: UInt16) {
        self = Self.allCases.first(where: { $0.ptzValue == ptzValue })!
    }
    
    var ptzValue: UInt16 {
        return UInt16(rawValue)
    }
}

enum PTZLed: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    #warning("TODO: should be sent on 2 bytes always....")
    case on  = 0x0000
    case off = 0x0210
    
    var description: String {
        switch self {
        case .on:   return "on"
        case .off:  return "off"
        }
    }
}

enum PTZStandByMode: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case on  = 0x12
    case off = 0x10
    
    var description: String {
        switch self {
        case .on:   return "on"
        case .off:  return "off"
        }
    }
}

enum PTZVideoOutput: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case on = 0x1a
    
    var description: String {
        switch self {
        case .on:   return "on"
        }
    }
}

enum PTZShutterSpeed: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case zero = 0x00
    
    var description: String {
        switch self {
        case .zero: return "zero"
        }
    }
}

enum PTZMuteState: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case unmute = 0x08
    
    var description: String {
        switch self {
        case .unmute: return "unmute"
        }
    }
}

enum PTZWhiteBalance: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case auto      =  1
    case manual    =  4
    case temp2300K =  5
    case temp2856K =  6
    case temp3450K =  7
    case temp4230K =  8
    case temp5200K =  9
    case temp6504K = 10
    
    var description: String {
        switch self {
        case .auto: return "auto"
        case .manual: return "manual"
        case .temp2300K: return "2300K"
        case .temp2856K: return "2856K"
        case .temp3450K: return "3450K"
        case .temp4230K: return "4230K"
        case .temp5200K: return "5200K"
        case .temp6504K: return "6504K"
        }
    }
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

struct PTZBrightness: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 20
    static var ptzOffset: Int = 117
    static var ptzScale: Double = 1
}

struct PTZSaturation: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 11
    static var ptzOffset: Int = 122
    static var ptzScale: Double = 1
}

struct PTZGain: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    #warning("TODO: find out max gain")
    static var maxValue: Int = 50
    static var ptzOffset: Int = 95 // 33 should be 01 00, 37 should be 01 04
    static var ptzScale: Double = 1
}

struct PTZPositionPan: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 1_000
    static var ptzScale: Double = 0.02
}

struct PTZPositionTilt: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 250
    static var ptzScale: Double = 0.005
}

struct PTZPositionZoom: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -49_772
    static var maxValue: Int = 17_663
    static var ptzOffset: Int = 1146
    static var ptzScale: Double = 0.021739 // <- this one is perfect match to read values, but 0.0217246 is closer to our Set fixtures
    // FROM: (8D 41 51 24 00 03 68 00 00 7A 03) 00 00 40
    // TO:   (8D 41 51 24 00 03 68 00 00 7A 03) 02 05 79
    // 00 40 -> 05 F9
    // 64 => 1529
}
