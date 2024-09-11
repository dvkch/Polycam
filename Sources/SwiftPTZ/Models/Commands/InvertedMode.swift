//
//  InvertedMode.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZRequestSetInvertedMode: PTZRequest {
    let enabled: Bool
    var bytes: Bytes { buildBytes([0x41, 0x3e], PTZBool(rawValue: enabled)) }
    var description: String { "Set inverted mode \(enabled.onOffString)" }
}

struct PTZRequestGetInvertedMode: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x3e]) }
    var description: String { "Get inverted mode" }
}

struct PTZReplyInvertedMode: PTZReply {
    let enabled: Bool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x3e]) else { return nil }
        self.enabled = message.parseArgument(type: PTZBool.self, position: .single).rawValue
    }
    
    var description: String {
        return "InvertedMode(\(enabled.onOffString))"
    }
}
