//
//  Contrast.swift
//  PTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZContrast: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 20
    public static var ptzOffset: Int = 118
    public static var ptzScale: Double = 1
    public static var `default`: PTZContrast { .init(rawValue: 10) }
}

public struct PTZContrastState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "Contrast"
    public static var register: (UInt8, UInt8) = (0x01, 0x32)

    public var value: PTZContrast
    
    public init(_ value: PTZContrast, for variant: PTZNone) {
        self.value = value
    }
}
