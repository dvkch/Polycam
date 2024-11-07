//
//  VignetteCorrection.swift
//  PTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

/// Turn on/off the integrated vignette correction
/// Discovered by fuzzing
public struct PTZVignetteCorrectionState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "VignetteCorrection"
    public static var register: (UInt8, UInt8) = (0x01, 0x3D)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
