//
//  BacklightCompensation.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZBacklightCompensationState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "BacklightCompensation"
    public static var register: (UInt8, UInt8) = (0x02, 0x15)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}

