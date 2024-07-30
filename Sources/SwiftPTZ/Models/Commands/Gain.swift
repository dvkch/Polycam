//
//  Gain.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZGainMode: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case auto = 0x00
    case unknown1 = 0x01
    case unknown2 = 0x02
    case unknown3 = 0x03
    case unknown4 = 0x04
    case unknown5 = 0x05
    static var `default`: PTZGainMode { .auto }
    
    var description: String {
        switch self {
        case .auto:     return "auto"
        case .unknown1: return "1"
        case .unknown2: return "2"
        case .unknown3: return "3"
        case .unknown4: return "4"
        case .unknown5: return "5"
        }
    }
}

struct PTZGain: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 64
    static var ptzOffset: Int = 95 // 33 should be 01 00, 37 should be 01 04
    static var ptzScale: Double = 1
    static var testValues: [PTZGain] { Array(minValue...maxValue).map(Self.init(rawValue:)) }
    static var `default`: PTZGain { .init(rawValue: 35) } // original system uses 37 for red, 33 for blue
}

#warning("understand this command, implement its getter and reply")
struct PTZRequestSetGainMode: PTZRequest {
    let gain: PTZGainMode
    var bytes: Bytes { buildBytes([0x41, 0x31], gain) }
    var description: String { "Set gain mode to \(gain.rawValue)" }
}

struct PTZRequestSetRedGain: PTZRequest {
    let gain: PTZGain
    var bytes: Bytes { buildBytes([0x43, 0x42], gain) }
    var description: String { "Set red gain to \(gain.rawValue)" }
}

struct PTZRequestSetBlueGain: PTZRequest {
    let gain: PTZGain
    var bytes: Bytes { buildBytes([0x43, 0x43], gain) }
    var description: String { "Set blue gain to \(gain.rawValue)" }
}

struct PTZRequestGetGainMode: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x31]) }
    var description: String { "Get gain mode" }
}

struct PTZRequestGetRedGain: PTZRequest {
    var bytes: Bytes { buildBytes([0x03, 0x42]) }
    var description: String { "Get red gain" }
}

struct PTZRequestGetBlueGain: PTZRequest {
    var bytes: Bytes { buildBytes([0x03, 0x43]) }
    var description: String { "Get blue gain" }
}

struct PTZReplyGainMode: PTZReply {
    let gain: PTZGainMode
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x31]) else { return nil }
        self.gain = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "GainMode(\(gain.rawValue))"
    }
}

struct PTZReplyRedGain: PTZReply {
    let gain: PTZGain
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x42]) else { return nil }
        self.gain = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "RedGain(\(gain.rawValue))"
    }
}

struct PTZReplyBlueGain: PTZReply {
    let gain: PTZGain

    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x43]) else { return nil }
        self.gain = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "BlueGain(\(gain.rawValue))"
    }
}

