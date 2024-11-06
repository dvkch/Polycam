//
//  WideDynamicRange.swift
//  SwiftPTZ
//
//  Created by syan on 24/10/2024.
//

import Foundation
import PTZMessaging

internal struct PTZWideDynamicRangeState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "WideDynamicRange"
    static var register: (UInt8, UInt8) = (0x01, 0x34)

    var value: PTZBool
    
    init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
