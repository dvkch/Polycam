//
//  MireMode.swift
//
//
//  Created by syan on 06/08/2024.
//

import Foundation
import PTZMessaging

public struct PTZMireState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "Mire"
    public static var register: (UInt8, UInt8) = (0x01, 0x10)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
