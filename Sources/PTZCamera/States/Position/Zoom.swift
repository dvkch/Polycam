//
//  Zoom.swift
//  PTZ
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZZoom: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 100
    public static var ptzMin: UInt16 = 0x40
    public static var ptzMax: UInt16 = 0x08_B5
    public static var unit: String = ""
    public static var `default`: Self = .min
}

internal struct PTZZoomOriginalAPI: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    static let minValue: Int = -49_772
    static let maxValue: Int = 17_663
    static let ptzMin: UInt16 = 0x40
    static let ptzMax: UInt16 = 0x08_B5
    static let unit: String = ""
    static let `default`: Self = .min
    // FROM: (8D 41 51 24 00 03 68 00 00 7A 03) 00 00 40
    // TO:   (8D 41 51 24 00 03 68 00 00 7A 03) 02 05 79
    // 00 40 -> 05 F9
    // 64 => 1529
}

/// Controls the zoom position.
/// Discovered by fuzzing
public struct PTZZoomState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "Zoom"
    public static let register: PTZRegister<PTZNone> = .init(0x03, 0x02)
    
    public var value: PTZZoom
    
    public init(_ value: PTZZoom, for variant: PTZNone) {
        self.value = value
    }
}
