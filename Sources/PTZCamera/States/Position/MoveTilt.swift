//
//  MoveTilt.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZTiltDirection: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
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

#warning("can go from 10 to 1F")
public enum PTZTiltSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x11
    case speed2 = 0x13
    case speed3 = 0x15
    case speed4 = 0x17
    case speed5 = 0x19
    public static var `default`: PTZTiltSpeed { .speed3 }
    
    public var description: String {
        switch self {
        case .speed1: return "20%"
        case .speed2: return "40%"
        case .speed3: return "60%"
        case .speed4: return "80%"
        case .speed5: return "100%"
        }
    }
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

