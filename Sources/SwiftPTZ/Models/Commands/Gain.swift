//
//  Gain.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZGain: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 64
    static var ptzOffset: Int = 95 // 33 should be 01 00, 37 should be 01 04
    static var ptzScale: Double = 1
    static var testValues: [PTZGain] { Array(minValue...maxValue).map(Self.init(rawValue:)) }
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

struct PTZRequestGetRedGain: PTZRequest {
    var bytes: Bytes { buildBytes([0x03, 0x42]) }
    var description: String { "Get red gain" }
}

struct PTZRequestGetBlueGain: PTZRequest {
    var bytes: Bytes { buildBytes([0x03, 0x43]) }
    var description: String { "Get blue gain" }
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

