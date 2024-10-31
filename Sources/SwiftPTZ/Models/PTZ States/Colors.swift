//
//  Colors.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZColorsState: PTZSingleValueState {
    static var name: String = "Colors"
    static var register: (UInt8, UInt8) = (0x01, 0x3A)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
}
