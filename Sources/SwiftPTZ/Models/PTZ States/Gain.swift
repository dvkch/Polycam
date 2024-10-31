//
//  Gain.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

// Kind of an equivalent to ISO
enum PTZGainMode: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case gain0dB    = 0x00
    case gain3dB    = 0x01
    case gain6dB    = 0x02
    case gain9dB    = 0x03
    case gain12dB   = 0x04
    case auto       = 0x05
    static var `default`: PTZGainMode { .auto }
    
    var description: String {
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

struct PTZEffectiveGain: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 70
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 5
    static var `default`: PTZEffectiveGain { .init(rawValue: 0) }
    var description: String { "\(rawValue)dB" }
}

struct PTZColorGain: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 64
    static var ptzOffset: Int = 95 // 33 should be 01 00, 37 should be 01 04
    static var ptzScale: Double = 1
    static var `default`: PTZColorGain { .init(rawValue: 35) } // original system uses 37 for red, 33 for blue
}

struct PTZGainModeState: PTZSingleValueState {
    static var name: String = "GainMode"
    static var register: (UInt8, UInt8) = (0x01, 0x31)
    
    var value: PTZGainMode
    
    init(_ value: PTZGainMode) {
        self.value = value
    }
    
    var waitingTimeIfExecuted: TimeInterval { 0.5 }
}

struct PTZRedGainState: PTZSingleValueState {
    static var name: String = "RedGain"
    static var register: (UInt8, UInt8) = (0x03, 0x42)
    
    var value: PTZColorGain
    
    init(_ value: PTZColorGain) {
        self.value = value
    }
}

struct PTZBlueGainState: PTZSingleValueState {
    static var name: String = "BlueGain"
    static var register: (UInt8, UInt8) = (0x03, 0x43)
    
    var value: PTZColorGain
    
    init(_ value: PTZColorGain) {
        self.value = value
    }
}

struct PTZEffectiveGainState: PTZSingleValueState {
    static var name: String = "EffectiveGain"
    static var register: (UInt8, UInt8) = (0x03, 0x26)
    
    var value: PTZEffectiveGain
    
    init(_ value: PTZEffectiveGain) {
        self.value = value
    }
    
    #warning("mark is read only")
}
