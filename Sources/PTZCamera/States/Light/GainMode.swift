//
//  GainMode.swift
//  PTZ
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public enum PTZGainMode: UInt16, PTZEnumValue {
    case gain0dB    = 0x00
    case gain3dB    = 0x01
    case gain6dB    = 0x02
    case gain9dB    = 0x03
    case gain12dB   = 0x04
    case auto       = 0x05
    public static let `default`: Self = .auto
    
    public var description: String {
        switch self {
        case .gain0dB:  return "0dB"
        case .gain3dB:  return "3dB"
        case .gain6dB:  return "6dB"
        case .gain9dB:  return "9dB"
        case .gain12dB: return "12dB"
        case .auto:     return "auto"
        }
    }
}

/// Controls the ISO
/// Discovered in the original application's logs, extended through fuzzing
public struct PTZGainModeState: PTZParseableState, PTZReadable, PTZWritable {
    public static var name: String = "GainMode"
    public static var register: PTZRegister<PTZNone> = .init(0x01, 0x31)
    
    public var value: PTZGainMode
    
    public init(_ value: PTZGainMode, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), waitingTimeIfExecuted: 0.5)
    }
}
