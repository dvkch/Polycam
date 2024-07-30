//
//  AutoExposure.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZRequestSetAutoExposure: PTZRequest {
    let enabled: Bool
    var bytes: Bytes { buildBytes([0x42, 0x11], PTZBool(rawValue: enabled)) }
    var description: String { "Set auto exposure \(enabled.onOffString)" }
}

struct PTZRequestGetAutoExposure: PTZRequest {
    var bytes: Bytes { buildBytes([0x02, 0x11]) }
    var description: String { "Get auto exposure" }
}

struct PTZReplyAutoExposure: PTZReply {
    let enabled: Bool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x42, 0x11]) else { return nil }
        self.enabled = message.parseArgument(type: PTZBool.self, position: .single).rawValue
    }
    
    var description: String {
        return "AutoExposure(\(enabled))"
    }
}
