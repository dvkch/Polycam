//
//  Sharpness.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZSharpness: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 1
    public static var maxValue: Int = 11
    public static var ptzOffset: Int = 122
    public static var ptzScale: Double = 1
    public static var `default`: PTZSharpness { .init(rawValue: 6) }
}

/// Controls the image's sharpness
/// Discovered in the original application
public struct PTZSharpnessState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "Sharpness"
    public static var register: (UInt8, UInt8) = (0x03, 0x3D)
    
    public var value: PTZSharpness
    
    public init(_ value: PTZSharpness, for variant: PTZNone) {
        self.value = value
    }
}
