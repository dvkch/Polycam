//
//  MireMode.swift
//
//
//  Created by syan on 06/08/2024.
//

import Foundation

struct PTZRequestSetMireMode: PTZRequest {
    let enabled: Bool
    var bytes: Bytes { buildBytes([0x41, 0x10], PTZBool(rawValue: enabled)) }
    var description: String { "Set mire mode \(enabled.onOffString)" }
}

struct PTZRequestGetMireMode: PTZGetRequest {
    typealias Reply = PTZReplyMireMode
    var bytes: Bytes { buildBytes([0x01, 0x10]) }
    var description: String { "Get mire mode" }
}

struct PTZReplyMireMode: PTZReply {
    let enabled: Bool

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x10]) else { return nil }
        self.enabled = message.parseArgument(type: PTZBool.self, position: .single).rawValue
    }
    
    var description: String {
        return "MireMode(\(enabled.onOffString))"
    }
}
