//
//  MoveFocus.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZFocusDirection: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case far    = 0x09
    case near   = 0x0A
    case stop   = 0x0B

    public var description: String {
        switch self {
        case .far:  return "far"
        case .near: return "near"
        case .stop: return "stop"
        }
    }
}

public enum PTZFocusSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x00
    case speed2 = 0x01
    case speed3 = 0x02
    case speed4 = 0x03
    public static var `default`: PTZFocusSpeed { .speed1 }

    public var description: String {
        switch self {
        case .speed1: return "25%"
        case .speed2: return "50%"
        case .speed3: return "75%"
        case .speed4: return "100%"
        }
    }
}

/// Starts focusing in the given direction at the requested speed. This is only possible when `PTZAutoFocusState` is `off`.
/// Discovered by fuzzing
public struct PTZMoveFocusAction: PTZState, PTZWriteable {
    public static var name: String { "MoveFocus" }
    public var variant: PTZFocusDirection
    public var value: PTZFocusSpeed
    
    public init(_ value: PTZFocusSpeed, for variant: PTZFocusDirection) {
        self.variant = variant
        self.value = value
    }
    
    public func setMessage() -> PTZMessage {
        switch variant {
        case .far, .near:   return .init((0x45, UInt8(variant.rawValue)), value)
        case .stop:         return .init((0x45, UInt8(variant.rawValue)))
        }
    }
}

