//
//  PTZValue.swift
//  PTZ
//
//  Created by syan on 25/06/2024.
//

import Foundation

public protocol PTZValue: RawRepresentable, CustomStringConvertible, Equatable, CaseIterable, CLIDecodable, JSONEncodable where RawValue: Equatable {
    init(ptzValue: UInt16)
    var ptzValue: UInt16 { get }
}

public extension PTZValue {
    static func ==(lhs: Self, rhs: Self) -> Bool {
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
