//
//  WideDynamicRange.swift
//  SwiftPTZ
//
//  Created by syan on 24/10/2024.
//

import Foundation

struct PTZRequestSetWideDynamicRange: PTZRequest {
    let enabled: PTZBool
    var message: PTZMessage { .init([0x41, 0x34], enabled) }
    var description: String { "Set wide dynamic range \(enabled)" }
}

struct PTZRequestGetWideDynamicRange: PTZGetRequest {
    typealias Reply = PTZReplyWideDynamicRange
    var message: PTZMessage { .init([0x01, 0x34]) }
    var description: String { "Get wide dynamic range" }
}

struct PTZReplyWideDynamicRange: PTZSpecificReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x34]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "WideDynamicRange(\(enabled))"
    }
}
