//
//  Pan.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZPan: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 2000 // max bytes are 0F 50
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1
    public static var `default`: PTZPan { .mid }
}

internal struct PTZPanOriginalAPI: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 1_000
    static var ptzScale: Double = 0.02
    static var `default`: PTZPanOriginalAPI { .init(rawValue: 0) }
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
