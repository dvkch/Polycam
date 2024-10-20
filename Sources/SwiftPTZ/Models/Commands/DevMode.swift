//
//  DevMode.swift
//  SwiftPTZ
//
//  Created by syan on 20/10/2024.
//

import Foundation

struct PTZRequestSetDevMode: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x41, 0x0B], enabled) }
    var description: String { "Set dev mode \(enabled)" }
}

struct PTZRequestGetDevMode: PTZGetRequest {
    typealias Reply = PTZReplyDevMode
    var bytes: Bytes { buildBytes([0x01, 0x0B]) }
    var description: String { "Get dev mode" }
}

struct PTZReplyDevMode: PTZReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x0B]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "DevMode(\(enabled))"
    }
}
