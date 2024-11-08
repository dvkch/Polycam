//
//  Tilt.swift
//  PTZ
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZTilt: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = -1000
    public static let maxValue: Int = 1000
    public static let ptzMin: UInt16 = 0x00
    public static let ptzMax: UInt16 = 0x01_F4
    public static let unit: String = ""
    public static let `default`: Self = .mid
}

internal struct PTZTiltOriginalAPI: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzMin: UInt16 = 0x00
    static var ptzMax: UInt16 = 0x01_F4
    static var unit: String = ""
    static var `default`: Self = .mid
}

/// Controls the tilt position.
/// Discovered by fuzzing
public struct PTZTiltState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "Tilt"
    public static let register: PTZRegister<PTZNone> = .init(0x03, 0x05)
    
    public var value: PTZTilt
    
    public init(_ value: PTZTilt, for variant: PTZNone) {
        self.value = value
    }
}
