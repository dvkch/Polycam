//
//  DevMode.swift
//  SwiftPTZ
//
//  Created by syan on 20/10/2024.
//

import Foundation

struct PTZDevModeState: PTZSingleValueState {
    static var name: String = "DevMode"
    static var register: (UInt8, UInt8) = (0x01, 0x0B)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
}
