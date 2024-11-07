//
//  Saturation.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZSaturation: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 1
    public static var maxValue: Int = 11
    public static var ptzOffset: Int = 122
    public static var ptzScale: Double = 1
    public static var `default`: PTZSaturation { .init(rawValue: 6) }
}

/// Controls the image's saturation
/// Discovered in the original appplication's logs
public struct PTZSaturationState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "Saturation"
    public static var register: (UInt8, UInt8) = (0x03, 0x3E)
    
    public var value: PTZSaturation
    
    public init(_ value: PTZSaturation, for variant: PTZNone) {
        self.value = value
    }
}
