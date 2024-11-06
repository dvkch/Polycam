//
//  Byte.swift
//
//
//  Created by syan on 30/12/2023.
//

import Foundation

public typealias Byte = UInt8

extension Byte {
    public var hexString: String {
        String(format: "%02X", self)
    }

    public var binString: String {
        String(self, radix: 2).padding(toLength: 8, withPad: "0", startingAt: 0)
    }
}