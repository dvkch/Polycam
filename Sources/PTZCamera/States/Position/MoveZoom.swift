//
//  MoveZoom.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZZoomDirection: UInt8, PTZVariant {
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

public struct PTZZoomSpeed: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x00
    public static let ptzMax: UInt16 = 0x02
    public static let unit: String = "%"
    public static let `default`: Self = .mid
}

/// Starts zooming in the given direction at the requested speed.
/// Discovered in the original program's logs, extended by fuzzing
public struct PTZMoveZoomAction: PTZParseableState, PTZWritable {
    public static let name: String = "MoveZoom"
    public static let register: PTZRegister<PTZZoomDirection> = .init(0x05, 0x00)
    public var variant: PTZZoomDirection
    public var value: PTZZoomSpeed
    
    public init(_ value: PTZZoomSpeed, for variant: PTZZoomDirection) {
        self.variant = variant
        self.value = value
    }
    
    public func setMessage() -> PTZMessage {
        .init(Self.register.set(variant), (variant == .stop) ? nil : value)
    }
}
