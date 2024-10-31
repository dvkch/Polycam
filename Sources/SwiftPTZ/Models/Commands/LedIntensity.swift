//
//  LedIntensity.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZLedIntensity: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int { 0 }
    static var maxValue: Int { 15 }
    static var ptzOffset: Int { 0 }
    static var ptzScale: Double { 1 }
    static var `default`: PTZLedIntensity { .init(rawValue: 8) }
}

struct PTZRequestSetLedIntensity: PTZRequest {
    let red: PTZLedIntensity
    let green: PTZLedIntensity
    let blue: PTZLedIntensity
    var message: PTZMessage { .init([0x41, 0x25], .init(red, .raw8(3)), .init(blue, .raw8(4)), .init(green, .raw8(5))) }
    var description: String { "Set led intensity to (R=\(red), G=\(green), B=\(blue))" }
}

struct PTZRequestGetLedIntensity: PTZGetRequest {
    typealias Reply = PTZReplyLedIntensity
    var message: PTZMessage { .init([0x01, 0x25]) }
    var description: String { "Get led intensity" }
}

struct PTZReplyLedIntensity: PTZSpecificReply {
    let red: PTZLedIntensity
    let green: PTZLedIntensity
    let blue: PTZLedIntensity

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x25]) else { return nil }
        red = message.parseArgument(position: .raw8(3))
        blue = message.parseArgument(position: .raw8(4))
        green = message.parseArgument(position: .raw8(5))
    }
    
    var description: String {
        return "LedIntensity(R=\(red), G=\(green), B=\(blue))"
    }
}
