//
//  Move.swift
//
//
//  Created by syan on 15/07/2024.
//

import Foundation
import PTZMessaging

#warning("can go from 10 to 1F")
public enum PTZPanTiltSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x11
    case speed2 = 0x13
    case speed3 = 0x15
    case speed4 = 0x17
    case speed5 = 0x19
    public static var `default`: PTZPanTiltSpeed { .speed1 }
    
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

public enum PTZZoomSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x00
    case speed2 = 0x01
    case speed3 = 0x02
    public static var `default`: PTZZoomSpeed { .speed1 }

    public var description: String {
        switch self {
        case .speed1: return "30%"
        case .speed2: return "60%"
        case .speed3: return "100%"
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

public enum PTZPanDirection: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
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

public enum PTZZoomDirection: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case `in`   = 0x0C
    case `out`  = 0x0D
    case stop   = 0x0E

    public var description: String {
        switch self {
        case .in:   return "in"
        case .out:  return "out"
        case .stop: return "stop"
        }
    }
}

internal struct PTZMovePanAction: PTZState, PTZWriteable {
    static var name: String { "Pan" }
    var variant: PTZPanDirection
    var value: PTZPanTiltSpeed
    
    init(_ value: PTZPanTiltSpeed, for variant: PTZPanDirection) {
        self.variant = variant
        self.value = value
    }
    
    func setMessage() -> PTZMessage {
        switch variant {
        case .left, .right: return .init((0x45, UInt8(variant.rawValue)), value)
        case .stop:         return .init((0x45, UInt8(variant.rawValue)))
        }
    }
}

internal struct PTZMoveTiltAction: PTZState, PTZWriteable {
    static var name: String { "Tilt" }
    var variant: PTZTiltDirection
    var value: PTZPanTiltSpeed
    
    init(_ value: PTZPanTiltSpeed, for variant: PTZTiltDirection) {
        self.variant = variant
        self.value = value
    }
    
    func setMessage() -> PTZMessage {
        switch variant {
        case .up, .down:    return .init((0x45, UInt8(variant.rawValue)), value)
        case .stop:         return .init((0x45, UInt8(variant.rawValue)))
        }
    }
}

internal struct PTZMoveFocusAction: PTZState, PTZWriteable {
    static var name: String { "Focus" }
    var variant: PTZFocusDirection
    var value: PTZFocusSpeed
    
    init(_ value: PTZFocusSpeed, for variant: PTZFocusDirection) {
        self.variant = variant
        self.value = value
    }
    
    func setMessage() -> PTZMessage {
        switch variant {
        case .far, .near:   return .init((0x45, UInt8(variant.rawValue)), value)
        case .stop:         return .init((0x45, UInt8(variant.rawValue)))
        }
    }
}

internal struct PTZMoveZoomAction: PTZState, PTZWriteable {
    static var name: String { "Zoom" }
    var variant: PTZZoomDirection
    var value: PTZZoomSpeed
    
    init(_ value: PTZZoomSpeed, for variant: PTZZoomDirection) {
        self.variant = variant
        self.value = value
    }
    
    func setMessage() -> PTZMessage {
        switch variant {
        case .in, .out:     return .init((0x45, UInt8(variant.rawValue)), value)
        case .stop:         return .init((0x45, UInt8(variant.rawValue)))
        }
    }
}
