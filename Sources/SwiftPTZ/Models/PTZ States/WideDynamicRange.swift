//
//  WideDynamicRange.swift
//  SwiftPTZ
//
//  Created by syan on 24/10/2024.
//

import Foundation

struct PTZWideDynamicRangeState: PTZSingleValueState {
    static var name: String = "WideDynamicRange"
    static var register: (UInt8, UInt8) = (0x01, 0x34)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
}
