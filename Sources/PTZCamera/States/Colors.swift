//
//  Colors.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

internal struct PTZColorsState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "Colors"
    static var register: (UInt8, UInt8) = (0x01, 0x3A)

    var value: PTZBool
    
    init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
