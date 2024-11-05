//
//  Tilt.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZTilt: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 500 // max bytes are 03 74
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1
    public static var `default`: PTZTilt { .mid }
}

internal struct PTZTiltOriginalAPI: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 250
    static var ptzScale: Double = 0.005
    static var `default`: PTZTiltOriginalAPI { .init(rawValue: 0) }
}

internal struct PTZTiltState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "Tilt"
    static var register: (UInt8, UInt8) = (0x03, 0x05)
    
    var value: PTZTilt
    
    init(_ value: PTZTilt, for variant: PTZNone) {
        self.value = value
    }
}
