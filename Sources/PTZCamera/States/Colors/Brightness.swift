//
//  Brightness.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZBrightness: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 1
    public static var maxValue: Int = 20
    public static var ptzOffset: Int = 117
    public static var ptzScale: Double = 1
    public static var `default`: PTZBrightness { .init(rawValue: 11) }
}

public struct PTZBrightnessState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "Brightness"
    public static var register: (UInt8, UInt8) = (0x01, 0x33)

    public var value: PTZBrightness
    
    public init(_ value: PTZBrightness, for variant: PTZNone) {
        self.value = value
    }
}
