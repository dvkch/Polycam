//
//  BacklightCompensation.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

internal struct PTZBacklightCompensationState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "BacklightCompensation"
    static var register: (UInt8, UInt8) = (0x02, 0x15)

    var value: PTZBool
    
    init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}

