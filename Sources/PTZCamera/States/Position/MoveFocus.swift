//
//  MoveFocus.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public enum PTZFocusDirection: UInt8, PTZVariant {
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

public struct PTZFocusSpeed: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x00
    public static let ptzMax: UInt16 = 0x03
    public static let unit: String = "%"
    public static let `default`: Self = .mid
}

/// Starts focusing in the given direction at the requested speed. This is only possible when `PTZAutoFocusState` is `off`.
/// Discovered by fuzzing
public struct PTZMoveFocusAction: PTZParseableState, PTZWritable {
    public static let name: String = "MoveFocus"
    public static let register: PTZRegister<PTZFocusDirection> = .init(0x05, 0x00)
    public var variant: PTZFocusDirection
    public var value: PTZFocusSpeed
    
    public init(_ value: PTZFocusSpeed, for variant: PTZFocusDirection) {
        self.variant = variant
        self.value = value
    }
    
    public func setMessage() -> PTZMessage {
        .init(Self.register.set(variant), (variant == .stop) ? nil : value)
    }
    
    public func set() -> PTZRequest {
        return .init(
            name: "Set \(description)", message: setMessage(),
            modeConditionRescueRequests: [PTZAutoFocusState(.off).set()]
        )
    }
}

