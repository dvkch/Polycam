//
//  NoiseReduction.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZNoiseReductionState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "NoiseReduction"
    public static var register: (UInt8, UInt8) = (0x01, 0x3C)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
