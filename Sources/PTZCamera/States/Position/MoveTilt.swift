//
//  MoveTilt.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZTiltDirection: UInt8, PTZVariant {
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
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x10
    public static let ptzMax: UInt16 = 0x1F
    public static let unit: String = "%"
    public static let `default`: Self = .mid
}

/// Starts tilting in the given direction at the requested speed.
/// Discovered in the original program's logs, extended by fuzzing
public struct PTZMoveTiltAction: PTZParseableState, PTZWritable {
    public static let name: String = "MoveTilt"
    public static let register: PTZRegister<PTZTiltDirection> = .init(0x05, 0x00)
    public var variant: PTZTiltDirection
    public var value: PTZTiltSpeed
    
    public init(_ value: PTZTiltSpeed, for variant: PTZTiltDirection) {
        self.variant = variant
        self.value = value
    }
    
    public func setMessage() -> PTZMessage {
        .init(Self.register.set(variant), (variant == .stop) ? nil : value)
    }
}

