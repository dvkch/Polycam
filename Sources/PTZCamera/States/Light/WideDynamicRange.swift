//
//  WideDynamicRange.swift
//  PTZ
//
//  Created by syan on 24/10/2024.
//

import Foundation
import PTZMessaging

/// Controls the wide dynamic range. Or so it seems. It seems to work the same way as a backlight compensation, but even more
/// effective. This has been found through fuzzing, and there already was a setting for backlight compensation in the original
/// program's logs
/// Discovered by fuzzing
public struct PTZWideDynamicRangeState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "WideDynamicRange"
    public static var register: (UInt8, UInt8) = (0x01, 0x34)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
