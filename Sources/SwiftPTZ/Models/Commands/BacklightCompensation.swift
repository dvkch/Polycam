//
//  BacklightCompensation.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZRequestSetBacklightCompensation: PTZRequest {
    let enabled: Bool
    var bytes: Bytes { buildBytes([0x42, 0x15], PTZBool(rawValue: enabled)) }
    var description: String { "Set backlight compensation \(enabled.onOffString)" }
}

struct PTZRequestGetBacklightCompensation: PTZGetRequest {
    typealias Reply = PTZReplyBacklightCompensation
    var bytes: Bytes { buildBytes([0x02, 0x15]) }
    var description: String { "Get backlight compensation" }
}

struct PTZReplyBacklightCompensation: PTZReply {
    let enabled: Bool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x42, 0x15]) else { return nil }
        self.enabled = message.parseArgument(type: PTZBool.self, position: .single).rawValue
    }
    
    var description: String {
        return "BacklightCompensation(\(enabled))"
    }
}
