//
//  VignetteCorrection.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZRequestSetVignetteCorrection: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x41, 0x3D], enabled) }
    var description: String { "Set vignette correction \(enabled)" }
}

struct PTZRequestGetVignetteCorrection: PTZGetRequest {
    typealias Reply = PTZReplyVignetteCorrection
    var bytes: Bytes { buildBytes([0x01, 0x3D]) }
    var description: String { "Get vignette correction" }
}

struct PTZReplyVignetteCorrection: PTZReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x3D]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "VignetteCorrection(\(enabled))"
    }
}
