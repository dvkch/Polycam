//
//  GainBlue.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZGainBlueState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "GainBlue"
    public static var register: (UInt8, UInt8) = (0x03, 0x43)
    
    public var value: PTZColorGain
    
    public init(_ value: PTZColorGain, for variant: PTZNone) {
        self.value = value
    }
}
