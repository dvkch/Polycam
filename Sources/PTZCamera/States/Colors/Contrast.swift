//
//  Contrast.swift
//  PTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZContrast: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = Self.clamped(ptzValue) }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x76
    public static let ptzMax: UInt16 = 0x8A
    public static let unit: String = "%"
    public static let `default`: Self = .mid
}

/// Controls the image's contrast
/// Discovered by fuzzing
public struct PTZContrastState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "Contrast"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x32)

    public var value: PTZContrast
    
    public init(_ value: PTZContrast, for variant: PTZNone) {
        self.value = value
    }
}
