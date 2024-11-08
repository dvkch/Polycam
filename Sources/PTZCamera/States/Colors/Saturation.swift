//
//  Saturation.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZSaturation: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x7B
    public static let ptzMax: UInt16 = 0x85
    public static let unit: String = "%"
    public static let `default`: Self = .mid
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
