//
//  BacklightCompensation.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZRequestSetBacklightCompensation: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x42, 0x15], enabled) }
    var description: String { "Set backlight compensation \(enabled)" }
}

struct PTZRequestGetBacklightCompensation: PTZGetRequest {
    typealias Reply = PTZReplyBacklightCompensation
    var bytes: Bytes { buildBytes([0x02, 0x15]) }
    var description: String { "Get backlight compensation" }
}

struct PTZReplyBacklightCompensation: PTZSpecificReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x42, 0x15]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "BacklightCompensation(\(enabled))"
    }
}
