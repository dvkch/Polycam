//
//  Sharpness.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZSharpness: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 11
    static var ptzOffset: Int = 122
    static var ptzScale: Double = 1
    static var `default`: PTZSharpness { .init(rawValue: 6) }
}

struct PTZRequestSetSharpness: PTZRequest {
    let sharpness: PTZSharpness
    var message: PTZMessage { .init([0x43, 0x3d], sharpness) }
    var description: String { "Set sharpness to \(sharpness)" }
}

struct PTZRequestGetSharpness: PTZGetRequest {
    typealias Reply = PTZReplySharpness
    var message: PTZMessage { .init([0x03, 0x3d]) }
    var description: String { "Get sharpness" }
}

struct PTZReplySharpness: PTZSpecificReply {
    let sharpness: PTZSharpness
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x3d]) else { return nil }
        self.sharpness = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Sharpness(\(sharpness))"
    }
}
