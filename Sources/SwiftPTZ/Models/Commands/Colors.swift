//
//  Colors.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZRequestSetColors: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x41, 0x3A], enabled) }
    var description: String { "Set colors \(enabled)" }
}

struct PTZRequestGetColors: PTZGetRequest {
    typealias Reply = PTZReplyColors
    var bytes: Bytes { buildBytes([0x01, 0x3A]) }
    var description: String { "Get colors" }
}

struct PTZReplyColors: PTZSpecificReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x3A]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Colors(\(enabled))"
    }
}
