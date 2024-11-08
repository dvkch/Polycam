//
//  UInt32+PTZ.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation

internal extension UInt32 {
    init(b3: UInt8, b2: UInt8, b1: UInt8, b0: UInt8) {
        let value: UInt32 = (
            (UInt32(b0) <<  0) +
            (UInt32(b1) <<  8) +
            (UInt32(b2) << 16) +
            (UInt32(b3) << 24)
        )
        self = value
    }
    
    var parts: (b3: UInt8, b2: UInt8, b1: UInt8, b0: UInt8) {
        let b0 = UInt8( self        & 0xFF)
        let b1 = UInt8((self >>  8) & 0xFF)
        let b2 = UInt8((self >> 16) & 0xFF)
        let b3 = UInt8((self >> 24) & 0xFF)
        return (b3, b2, b1, b0)
    }
}

