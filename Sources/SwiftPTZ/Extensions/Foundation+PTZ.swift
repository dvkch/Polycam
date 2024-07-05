//
//  Foundation+PTZ.swift
//
//
//  Created by syan on 08/01/2024.
//

import Foundation

extension Bool {
    var onOffString: String {
        return self ? "on" : "off"
    }
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

