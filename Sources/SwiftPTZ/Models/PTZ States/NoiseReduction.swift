//
//  NoiseReduction.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZNoiseReductionState: PTZSingleValueState {
    static var name: String = "NoiseReduction"
    static var register: (UInt8, UInt8) = (0x01, 0x3C)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
}
