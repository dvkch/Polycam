//
//  DevMode.swift
//  PTZ
//
//  Created by syan on 20/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZDevModeState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "DevMode"
    public static var register: (UInt8, UInt8) = (0x01, 0x0B)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
