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