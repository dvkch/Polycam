//
//  Zoom.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZZoom: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 64
    public static var maxValue: Int = 2229 // max bytes are 11 35
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1
    public static var `default`: PTZZoom { .min }
}

internal struct PTZZoomOriginalAPI: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -49_772
    static var maxValue: Int = 17_663
    static var ptzOffset: Int = 1146
    static var ptzScale: Double = 0.021739 // <- this one is perfect match to read values, but 0.0217246 is closer to our Set fixtures
    static var `default`: PTZZoomOriginalAPI { .init(rawValue: 0) }
    // FROM: (8D 41 51 24 00 03 68 00 00 7A 03) 00 00 40
    // TO:   (8D 41 51 24 00 03 68 00 00 7A 03) 02 05 79
    // 00 40 -> 05 F9
    // 64 => 1529
}

internal struct PTZZoomState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "Zoom"
    static var register: (UInt8, UInt8) = (0x03, 0x02)
    
    var value: PTZZoom
    
    init(_ value: PTZZoom, for variant: PTZNone) {
        self.value = value
    }
}
