//
//  InvertedMode.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZRequestSetInvertedMode: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x41, 0x3e], enabled) }
    var description: String { "Set inverted mode \(enabled)" }
}

struct PTZRequestGetInvertedMode: PTZGetRequest {
    typealias Reply = PTZReplyInvertedMode
    var bytes: Bytes { buildBytes([0x01, 0x3e]) }
    var description: String { "Get inverted mode" }
}

struct PTZReplyInvertedMode: PTZSpecificReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x3e]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "InvertedMode(\(enabled))"
    }
}
