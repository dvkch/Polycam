//
//  NoiseReduction.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZRequestSetNoiseReduction: PTZRequest {
    let enabled: PTZBool
    var message: PTZMessage { .init([0x41, 0x3C], enabled) }
    var description: String { "Set noise reduction \(enabled)" }
}

struct PTZRequestGetNoiseReduction: PTZGetRequest {
    typealias Reply = PTZReplyNoiseReduction
    var message: PTZMessage { .init([0x01, 0x3C]) }
    var description: String { "Get noise reduction" }
}

struct PTZReplyNoiseReduction: PTZSpecificReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x3C]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "NoiseReduction(\(enabled))"
    }
}
