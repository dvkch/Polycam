//
//  Pan.swift
//  PTZ
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZPan: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = -100
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0
    public static let ptzMax: UInt16 = 0x07_D0
    public static let unit: String = ""
    public static let `default`: Self = .mid
}

internal struct PTZPanOriginalAPI: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzMin: UInt16 = 0
    static var ptzMax: UInt16 = 0x07_D0
    static var unit: String = ""
    static var `default`: Self = .mid
}

/// Controls the pan position.
/// Discovered by fuzzing
public struct PTZPanState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "Pan"
    public static var register: (UInt8, UInt8) = (0x03, 0x04)
    
    public var value: PTZPan
    
    public init(_ value: PTZPan, for variant: PTZNone) {
        self.value = value
    }
}
