//
//  MireMode.swift
//
//
//  Created by syan on 06/08/2024.
//

import Foundation

struct PTZMireState: PTZSingleValueState {
    static var name: String = "Mire"
    static var register: (UInt8, UInt8) = (0x01, 0x10)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
}
