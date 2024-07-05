//
//  File.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZVideoOutputMode: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case on = 0x1a
    
    var description: String {
        switch self {
        case .on:   return "on"
        }
    }
}

struct PTZRequestSetVideoOutputMode: PTZRequest {
    let mode: PTZVideoOutputMode
    var bytes: Bytes { buildBytes([0x41, 0x13], mode) }
    var description: String { "Set video output \(mode.description)" }
}

struct PTZRequestGetVideoOutputMode: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x13]) }
    var description: String { "Get video output" }
}

struct PTZReplyVideoOutputMode: PTZReply {
    let mode: PTZVideoOutputMode

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x13]) else { return nil }
        self.mode = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "VideoOutputMode(\(mode.description))"
    }
}
