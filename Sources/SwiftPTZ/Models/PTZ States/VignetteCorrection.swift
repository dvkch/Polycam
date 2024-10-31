//
//  VignetteCorrection.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZVignetteCorrectionState: PTZSingleValueState {
    static var name: String = "VignetteCorrection"
    static var register: (UInt8, UInt8) = (0x01, 0x3D)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
}
