//
//  AutoExposure.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZRequestSetAutoExposure: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x42, 0x11], enabled) }
    var description: String { "Set auto exposure \(enabled)" }
}

struct PTZRequestGetAutoExposure: PTZGetRequest {
    typealias Reply = PTZReplyAutoExposure
    var bytes: Bytes { buildBytes([0x02, 0x11]) }
    var description: String { "Get auto exposure" }
}

struct PTZReplyAutoExposure: PTZReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x42, 0x11]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "AutoExposure(\(enabled))"
    }
}
