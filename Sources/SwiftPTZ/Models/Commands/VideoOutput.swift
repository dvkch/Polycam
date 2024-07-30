//
//  File.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZVideoOutputMode: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
#warning("TEST ALL RESOLUTIONS")
#warning("TEST RESOLUTIONS WITHOUT THE EXTRA 0x10 (seems to be a parameter for something else, not sure what)")
    case resolution720p  = 0x10
    case resolution1080i = 0x18
    case resolution1080p = 0x1a
    
    var description: String {
        switch self {
        case .resolution720p:  return "720p"
        case .resolution1080i: return "1080i"
        case .resolution1080p: return "1080p"
        }
    }
    
    static var `default`: PTZVideoOutputMode { .resolution1080p }
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
