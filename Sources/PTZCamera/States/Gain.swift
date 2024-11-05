//
//  Gain.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

// Kind of an equivalent to ISO
public enum PTZGainMode: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case gain0dB    = 0x00
    case gain3dB    = 0x01
    case gain6dB    = 0x02
    case gain9dB    = 0x03
    case gain12dB   = 0x04
    case auto       = 0x05
    public static var `default`: PTZGainMode { .auto }
    
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

public struct PTZEffectiveGain: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 70
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 5
    public var description: String { "\(rawValue)dB" }
}

public struct PTZColorGain: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 1
    public static var maxValue: Int = 64
    public static var ptzOffset: Int = 95 // 33 should be 01 00, 37 should be 01 04
    public static var ptzScale: Double = 1
    public static var `default`: PTZColorGain { .init(rawValue: 35) } // original system uses 37 for red, 33 for blue
}

internal struct PTZGainModeState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "GainMode"
    static var register: (UInt8, UInt8) = (0x01, 0x31)
    
    var value: PTZGainMode
    
    init(_ value: PTZGainMode, for variant: PTZNone) {
        self.value = value
    }
    
    func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), waitingTimeIfExecuted: 0.5)
    }
}

internal struct PTZRedGainState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "RedGain"
    static var register: (UInt8, UInt8) = (0x03, 0x42)
    
    var value: PTZColorGain
    
    init(_ value: PTZColorGain, for variant: PTZNone) {
        self.value = value
    }
}

internal struct PTZBlueGainState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "BlueGain"
    static var register: (UInt8, UInt8) = (0x03, 0x43)
    
    var value: PTZColorGain
    
    init(_ value: PTZColorGain, for variant: PTZNone) {
        self.value = value
    }
}

internal struct PTZEffectiveGainState: PTZParseableState, PTZReadable {
    static var name: String = "EffectiveGain"
    static var register: (UInt8, UInt8) = (0x03, 0x26)
    
    var value: PTZEffectiveGain
    
    init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        self.value = message.parseArgument(position: .single)
    }
}
