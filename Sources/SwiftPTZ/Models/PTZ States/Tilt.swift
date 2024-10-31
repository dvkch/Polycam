//
//  Tilt.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation

struct PTZTilt: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 500 // max bytes are 03 74
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZTilt { .mid }
}

struct PTZTiltOriginalAPI: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 250
    static var ptzScale: Double = 0.005
    static var `default`: PTZTiltOriginalAPI { .init(rawValue: 0) }
}

struct PTZRequestSetTilt: PTZRequest {
    let tilt: PTZTilt
    var message: PTZMessage { .init([0x43, 0x05], tilt) }
    var description: String { "Set tilt to \(tilt)" }
}

struct PTZRequestGetTilt: PTZGetRequest {
    typealias Reply = PTZReplyTilt
    var message: PTZMessage { .init([0x03, 0x05]) }
    var description: String { "Get tilt" }
}

struct PTZReplyTilt: PTZSpecificReply {
    let tilt: PTZTilt
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x05]) else { return nil }
        self.tilt = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Tilt(\(tilt))"
    }
}
