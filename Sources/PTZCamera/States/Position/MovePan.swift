//
//  MovePan.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

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

#warning("can go from 10 to 1F")
public enum PTZPanSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x11
    case speed2 = 0x13
    case speed3 = 0x15
    case speed4 = 0x17
    case speed5 = 0x19
    public static var `default`: PTZPanSpeed { .speed4 }
    
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

public struct PTZMovePanAction: PTZState, PTZWriteable {
    public static var name: String { "Pan" }
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
