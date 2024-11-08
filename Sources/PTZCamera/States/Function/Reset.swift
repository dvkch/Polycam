//
//  Reset.swift
//  
//
//  Created by syan on 11/09/2024.
//

import Foundation
import PTZMessaging

public enum PTZReset: UInt16, PTZEnumValue {
    case settings          = 0x00
    case settingsAndMotors = 0x01
    
    internal var expectedRunTime: TimeInterval {
        switch self {
        case .settings:          return 5
        case .settingsAndMotors: return 10
        }
    }
    
    public var description: String {
        switch self {
        case .settings:           return "settings"
        case .settingsAndMotors:  return "settings and motors"
        }
    }
}

/// Resets the device registers to a default state, including video output and position
/// Discovered by fuzzing
public struct PTZResetAction: PTZParseableState, PTZWritable {
    public static let name: String = "Reset"
    public static let register: PTZRegister<PTZNone> = .init(0x05, 0x32)

    public var value: PTZReset
    
    public init(_ value: PTZReset, for variant: PTZNone = .init()) {
        self.value = value
    }

    public func set() -> PTZRequest {
        return .init(name: "Start \(description)", message: setMessage(), waitingTimeIfExecuted: value.expectedRunTime)
    }
}
