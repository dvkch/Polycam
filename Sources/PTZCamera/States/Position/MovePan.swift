//
//  MovePan.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZPanDirection: UInt16, PTZEnumValue {
    case right  = 0x00
    case left   = 0x01
    case stop   = 0x02

    public var description: String {
        switch self {
        case .right:    return "right"
        case .left:     return "left"
        case .stop:     return "stop"
        }
    }
}

public struct PTZPanSpeed: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x10
    public static let ptzMax: UInt16 = 0x1F
    public static let unit: String = "%"
    public static let `default`: Self = .mid
}

/// Starts panning in the given direction at the requested speed.
/// Discovered in the original program's logs, extended by fuzzing
public struct PTZMovePanAction: PTZState, PTZWriteable {
    public static var name: String { "MovePan" }
    public var variant: PTZPanDirection
    public var value: PTZPanSpeed
    
    public init(_ value: PTZPanSpeed, for variant: PTZPanDirection) {
        self.variant = variant
        self.value = value
    }
    
    public func setMessage() -> PTZMessage {
        switch variant {
        case .left, .right: return .init((0x45, UInt8(variant.rawValue)), value)
        case .stop:         return .init((0x45, UInt8(variant.rawValue)))
        }
    }
}
