//
//  MoveTilt.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZTiltDirection: UInt16, PTZEnumValue {
    case up     = 0x03
    case down   = 0x04
    case stop   = 0x05

    public var description: String {
        switch self {
        case .up:   return "up"
        case .down: return "down"
        case .stop: return "stop"
        }
    }
}

public struct PTZTiltSpeed: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 100
    public static var ptzMin: UInt16 = 0x10
    public static var ptzMax: UInt16 = 0x1F
    public static var unit: String = "%"
    public static var `default`: Self = .mid
}

/// Starts tilting in the given direction at the requested speed.
/// Discovered in the original program's logs, extended by fuzzing
public struct PTZMoveTiltAction: PTZState, PTZWriteable {
    public static var name: String { "MoveTilt" }
    public var variant: PTZTiltDirection
    public var value: PTZTiltSpeed
    
    public init(_ value: PTZTiltSpeed, for variant: PTZTiltDirection) {
        self.variant = variant
        self.value = value
    }
    
    public func setMessage() -> PTZMessage {
        switch variant {
        case .up, .down:    return .init((0x45, UInt8(variant.rawValue)), value)
        case .stop:         return .init((0x45, UInt8(variant.rawValue)))
        }
    }
}

