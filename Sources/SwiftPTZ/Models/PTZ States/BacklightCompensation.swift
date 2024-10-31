//
//  BacklightCompensation.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZBacklightCompensationState: PTZSingleValueState {
    static var name: String = "BacklightCompensation"
    static var register: (UInt8, UInt8) = (0x02, 0x15)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
}

