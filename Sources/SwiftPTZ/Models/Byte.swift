//
//  Byte.swift
//
//
//  Created by syan on 30/12/2023.
//

import Foundation

typealias Byte = UInt8

extension Byte {
    var stringRepresentation: String {
        String(format: "%02X", self)
    }
}

extension [Byte] {
    var stringRepresentation: String {
        self
            .map { $0.stringRepresentation }
            .joined(separator: " ")
    }
    
    enum Comparison {
        case equal, closeEnough, different
    }

    func compare(_ other: [Byte], allowingVarianceOfOneAtIndex imperfectionIndex: Int) -> Comparison {
        guard self.count == other.count else { return .different }
        
        let mismatchIndices = (0..<count).filter { self[$0] != other[$0] }
        if mismatchIndices.isEmpty {
            return .equal
        }
        
        if mismatchIndices == [imperfectionIndex] && abs(Int(self[imperfectionIndex]) - Int(other[imperfectionIndex])) == 1 {
            return .closeEnough
        }
        
        return .different
    }
}

extension String {
    var bytes: [Byte] {
        self
            .components(separatedBy: " ")
            .map { UInt8($0, radix: 16)! }
    }
}

extension UInt16 {
    var requestBytes: (lo: UInt8, loRetainer: Bool, hi: UInt8) {
        var lo = UInt8(self & 0xFF)
        var loRetainer = false
        if lo >= 128 {
            lo -= 128
            loRetainer = true
        }
        let hi = UInt8((self >> 8) & 0xFF)
        return (lo, loRetainer, hi)
    }
    
    init(from bytes: [UInt8], loIndex: Int, hiIndex: Int, loRetainerIndex: Int, loRetainerMask: UInt8) {
        assert(loIndex < bytes.count)
        assert(loRetainerIndex < bytes.count)
        assert(hiIndex < bytes.count)
        
        let hi = bytes[hiIndex]
        var lo = bytes[loIndex]
        let lowRetainer = (bytes[loRetainerIndex] & loRetainerMask) > 0
        if lowRetainer {
            lo += 128
        }
        
        self = UInt16(hi) << 8 + UInt16(lo)
    }
}

