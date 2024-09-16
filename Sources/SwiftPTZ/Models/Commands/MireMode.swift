//
//  MireMode.swift
//
//
//  Created by syan on 06/08/2024.
//

import Foundation

struct PTZRequestSetMireMode: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x41, 0x10], enabled) }
    var description: String { "Set mire mode \(enabled)" }
}

struct PTZRequestGetMireMode: PTZGetRequest {
    typealias Reply = PTZReplyMireMode
    var bytes: Bytes { buildBytes([0x01, 0x10]) }
    var description: String { "Get mire mode" }
}

struct PTZReplyMireMode: PTZReply {
    let enabled: PTZBool

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x10]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "MireMode(\(enabled))"
    }
}
