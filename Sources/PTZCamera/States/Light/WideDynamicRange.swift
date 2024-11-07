//
//  WideDynamicRange.swift
//  PTZ
//
//  Created by syan on 24/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZWideDynamicRangeState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "WideDynamicRange"
    public static var register: (UInt8, UInt8) = (0x01, 0x34)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
