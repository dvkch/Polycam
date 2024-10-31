//
//  Saturation.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZSaturation: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 11
    static var ptzOffset: Int = 122
    static var ptzScale: Double = 1
    static var `default`: PTZSaturation { .init(rawValue: 6) }
}

struct PTZRequestSetSaturation: PTZRequest {
    let saturation: PTZSaturation
    var message: PTZMessage { .init([0x43, 0x3e], saturation) }
    var description: String { "Set saturation to \(saturation)" }
}

struct PTZRequestGetSaturation: PTZGetRequest {
    typealias Reply = PTZReplySaturation
    var message: PTZMessage { .init([0x03, 0x3e]) }
    var description: String { "Get saturation" }
}

struct PTZReplySaturation: PTZSpecificReply {
    let saturation: PTZSaturation
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x3e]) else { return nil }
        self.saturation = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Saturation(\(saturation))"
    }
}
