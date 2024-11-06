//
//  MoveZoom.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

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

public struct PTZMoveZoomAction: PTZState, PTZWriteable {
    public static var name: String { "Zoom" }
    public var variant: PTZZoomDirection
    public var value: PTZZoomSpeed
    
    public init(_ value: PTZZoomSpeed, for variant: PTZZoomDirection) {
        self.variant = variant
        self.value = value
    }
    
    public func setMessage() -> PTZMessage {
        switch variant {
        case .in, .out:     return .init((0x45, UInt8(variant.rawValue)), value)
        case .stop:         return .init((0x45, UInt8(variant.rawValue)))
        }
    }
}
