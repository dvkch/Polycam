//
//  Brightness.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZBrightness: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 20
    static var ptzOffset: Int = 117
    static var ptzScale: Double = 1
    static var testValues: [PTZBrightness] { Array(minValue...maxValue).map(Self.init(rawValue:)) }
    static var `default`: PTZBrightness { .init(rawValue: 11) }
}

struct PTZRequestSetBrightness: PTZRequest {
    let brightness: PTZBrightness
    var bytes: Bytes { buildBytes([0x41, 0x33], brightness) }
    var description: String { "Set brightness to \(brightness.rawValue)" }
}

struct PTZRequestGetBrightness: PTZGetRequest {
    typealias Reply = PTZReplyBrightness
    var bytes: Bytes { buildBytes([0x01, 0x33]) }
    var description: String { "Get Brightness" }
}

struct PTZReplyBrightness: PTZReply {
    let brightness: PTZBrightness
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x33]) else { return nil }
        self.brightness = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Brightness(\(brightness.rawValue))"
    }
}
