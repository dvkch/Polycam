//
//  Brightness.swift
//  PTZ
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZBrightness: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x76
    public static let ptzMax: UInt16 = 0x8A
    public static let unit: String = "%"
    public static let `default`: Self = .mid
}

/// Controls the image's brightness
/// Discovered in the original appplication's logs
public struct PTZBrightnessState: PTZParseableState, PTZReadable, PTZWritable {
    public static var name: String = "Brightness"
    public static var register: PTZRegister<PTZNone> = .init(0x01, 0x33)

    public var value: PTZBrightness
    
    public init(_ value: PTZBrightness, for variant: PTZNone) {
        self.value = value
    }
}
