//
//  InvertedMode.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZInvertedState: PTZSingleValueState {
    static var name: String = "Inverted"
    static var register: (UInt8, UInt8) = (0x01, 0x3E)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
}
