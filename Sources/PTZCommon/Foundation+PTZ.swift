//
//  Foundation+PTZ.swift
//
//
//  Created by syan on 08/01/2024.
//

import Foundation

infix operator ||= : AssignmentPrecedence

extension Bool {
    static func ||= (lhs: inout Self, rhs: Self) {
        lhs = lhs || rhs
    }
}

func with<T, U>(_ value: T, _ closure: (T) -> U) -> U {
    closure(value)
}

protocol BinaryNumber: SignedNumeric, Comparable {
    init(_ value: UInt16)
    static func / (lhs: Self, rhs: Self) -> Self
    var uint16: UInt16 { get }
}

extension Int: BinaryNumber {
    var uint16: UInt16 { return UInt16(self) }
}

extension Float: BinaryNumber {
    var uint16: UInt16 { return UInt16(self) }
}

extension Double: BinaryNumber {
    var uint16: UInt16 { return UInt16(self) }
}

func speak<T: CustomStringConvertible>(_ value: T) {
    speak(value.description)
}

func speak(_ string: String) {
    #if os(macOS)
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
    process.arguments = ["say", string]
    try? process.run()
    #endif
}

func during(seconds: TimeInterval, action: () -> ()) {
    let startDate = Date()
    while Date().timeIntervalSince(startDate) <= seconds {
        action()
    }
}

extension UInt32 {
    public init(b3: UInt8, b2: UInt8, b1: UInt8, b0: UInt8) {
        self.init(
            (UInt32(b0) <<  0) +
            (UInt32(b1) <<  8) +
            (UInt32(b2) << 16) +
            (UInt32(b3) << 24)
        )
    }
    
    public var parts: (b3: UInt8, b2: UInt8, b1: UInt8, b0: UInt8) {
        let b0 = UInt8( self        & 0xFF)
        let b1 = UInt8((self >>  8) & 0xFF)
        let b2 = UInt8((self >> 16) & 0xFF)
        let b3 = UInt8((self >> 24) & 0xFF)
        return (b3, b2, b1, b0)
    }
}
