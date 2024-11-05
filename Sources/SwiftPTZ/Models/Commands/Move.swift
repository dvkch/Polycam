//
//  Move.swift
//
//
//  Created by syan on 15/07/2024.
//

import Foundation

#warning("can go from 10 to 1F")
enum PTZPanTiltSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x11
    case speed2 = 0x13
    case speed3 = 0x15
    case speed4 = 0x17
    case speed5 = 0x19
    static var `default`: PTZPanTiltSpeed { .speed1 }
    
    var description: String {
        switch self {
        case .speed1: return "20%"
        case .speed2: return "40%"
        case .speed3: return "60%"
        case .speed4: return "80%"
        case .speed5: return "100%"
        }
    }
}

enum PTZZoomSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x00
    case speed2 = 0x01
    case speed3 = 0x02
    static var `default`: PTZZoomSpeed { .speed1 }

    var description: String {
        switch self {
        case .speed1: return "30%"
        case .speed2: return "60%"
        case .speed3: return "100%"
        }
    }
}

enum PTZFocusSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x00
    case speed2 = 0x01
    case speed3 = 0x02
    case speed4 = 0x03
    static var `default`: PTZFocusSpeed { .speed1 }

    var description: String {
        switch self {
        case .speed1: return "25%"
        case .speed2: return "50%"
        case .speed3: return "75%"
        case .speed4: return "100%"
        }
    }
}

enum PTZPanDirection: Byte, CaseIterable, CustomStringConvertible {
    case right  = 0x00
    case left   = 0x01
    case stop   = 0x02

    var description: String {
        switch self {
        case .right:    return "right"
        case .left:     return "left"
        case .stop:     return "stop"
        }
    }
}

enum PTZTiltDirection: Byte, CaseIterable, CustomStringConvertible {
    case up     = 0x03
    case down   = 0x04
    case stop   = 0x05

    var description: String {
        switch self {
        case .up:   return "up"
        case .down: return "down"
        case .stop: return "stop"
        }
    }
}

enum PTZFocusDirection: Byte, CaseIterable, CustomStringConvertible {
    case far    = 0x09
    case near   = 0x0A
    case stop   = 0x0B

    var description: String {
        switch self {
        case .far:  return "far"
        case .near: return "near"
        case .stop: return "stop"
        }
    }
}

enum PTZZoomDirection: Byte, CaseIterable, CustomStringConvertible {
    case `in`   = 0x0C
    case `out`  = 0x0D
    case stop   = 0x0E

    var description: String {
        switch self {
        case .in:   return "in"
        case .out:  return "out"
        case .stop: return "stop"
        }
    }
}

struct PTZMovePanAction: PTZWriteable {
    static var name: String { "Pan" }
    var variant: PTZPanDirection
    var value: PTZPanTiltSpeed
    
    init(_ value: PTZPanTiltSpeed, for variant: PTZPanDirection) {
        self.variant = variant
        self.value = value
    }
    
    func set() -> PTZRequest {
        switch variant {
        case .left, .right: return .init(name: description, message: .init((0x45, variant.rawValue), value))
        case .stop:         return .init(name: description, message: .init((0x45, variant.rawValue)))
        }
    }
}

struct PTZMoveTiltAction: PTZWriteable {
    static var name: String { "Tilt" }
    var variant: PTZTiltDirection
    var value: PTZPanTiltSpeed
    
    init(_ value: PTZPanTiltSpeed, for variant: PTZTiltDirection) {
        self.variant = variant
        self.value = value
    }
    
    func set() -> PTZRequest {
        switch variant {
        case .up, .down:    return .init(name: description, message: .init((0x45, variant.rawValue), value))
        case .stop:         return .init(name: description, message: .init((0x45, variant.rawValue)))
        }
    }
}

struct PTZMoveFocusAction: PTZWriteable {
    static var name: String { "Focus" }
    var variant: PTZFocusDirection
    var value: PTZFocusSpeed
    
    init(_ value: PTZFocusSpeed, for variant: PTZFocusDirection) {
        self.variant = variant
        self.value = value
    }
    
    func set() -> PTZRequest {
        switch variant {
        case .far, .near:   return .init(name: description, message: .init((0x45, variant.rawValue), value))
        case .stop:         return .init(name: description, message: .init((0x45, variant.rawValue)))
        }
    }
}

struct PTZMoveZoomAction: PTZWriteable {
    static var name: String { "Zoom" }
    var variant: PTZZoomDirection
    var value: PTZZoomSpeed
    
    init(_ value: PTZZoomSpeed, for variant: PTZZoomDirection) {
        self.variant = variant
        self.value = value
    }
    
    func set() -> PTZRequest {
        switch variant {
        case .in, .out:     return .init(name: description, message: .init((0x45, variant.rawValue), value))
        case .stop:         return .init(name: description, message: .init((0x45, variant.rawValue)))
        }
    }
}
