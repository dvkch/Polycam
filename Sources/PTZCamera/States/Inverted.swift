//
//  Inverted.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

internal struct PTZInvertedState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "Inverted"
    static var register: (UInt8, UInt8) = (0x01, 0x3E)

    var value: PTZBool
    
    init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
