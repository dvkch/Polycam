//
//  GainBlue.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

/// Controls the blue channel gain, depends on the configured whitebalance
/// Discovered in the original application's logs
public struct PTZGainBlueState: PTZParseableState, PTZReadable, PTZWritable {
    public static var name: String = "GainBlue"
    public static var register: PTZRegister<PTZNone> = .init(0x03, 0x43)
    
    public var value: PTZColorGain
    
    public init(_ value: PTZColorGain, for variant: PTZNone) {
        self.value = value
    }
}
