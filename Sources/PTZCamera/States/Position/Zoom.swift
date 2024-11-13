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
    public init(ptzValue: UInt16) { self.ptzValue = Self.clamped(ptzValue) }
    public static let minValue: Int = 0
    public static let maxValue: Int = 1000
    public static let ptzMin: UInt16 = 0x40
    public static let ptzMax: UInt16 = 0x08_B5
    public static let unit: String = ""
    public static let `default`: Self = .min
}

internal struct PTZZoomOriginalAPI: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = Self.clamped(ptzValue) }
    static let minValue: Int = -49_772
    static let maxValue: Int = 17_663
    static let ptzMin: UInt16 = 0x40
    static let ptzMax: UInt16 = 0x08_B5
    static let unit: String = ""
    static let `default`: Self = .min
    
    init(rawValue: Int) {
        let ptzValue = UInt16(1146 + Int(Double(rawValue) * 0.021739))
        self.init(ptzValue: ptzValue)
    }
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
