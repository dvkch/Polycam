//
//  AutoFocus.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZRequestSetAutoFocus: PTZRequest {
    let enabled: Bool
    var bytes: Bytes { buildBytes([0x42, 0x09], PTZBool(rawValue: enabled)) }
    var description: String { "Set auto focus \(enabled.onOffString)" }
}

struct PTZRequestGetAutoFocus: PTZGetRequest {
    typealias Reply = PTZReplyAutoFocus
    var bytes: Bytes { buildBytes([0x02, 0x09]) }
    var description: String { "Get auto focus" }
}

struct PTZReplyAutoFocus: PTZReply {
    let enabled: Bool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x42, 0x09]) else { return nil }
        self.enabled = message.parseArgument(type: PTZBool.self, position: .single).rawValue
    }
    
    var description: String {
        return "AutoFocus(\(enabled))"
    }
}
