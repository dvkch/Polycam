//
//  Sharpness.swift
//  PTZ
//
//  Created by syan on 10/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZSharpness: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = Self.clamped(ptzValue) }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x7B
    public static let ptzMax: UInt16 = 0x85
    public static let unit: String = "%"
    public static let `default`: Self = .mid
}

/// Controls the image's sharpness
/// Discovered in the original application
public struct PTZSharpnessState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "Sharpness"
    public static let register: PTZRegister<PTZNone> = .init(0x03, 0x3D)
    
    public var value: PTZSharpness
    
    public init(_ value: PTZSharpness, for variant: PTZNone) {
        self.value = value
    }
}
