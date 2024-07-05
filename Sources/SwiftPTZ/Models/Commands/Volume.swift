//
//  Volume.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZVolume: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case unmute = 0x08
    
    var description: String {
        switch self {
        case .unmute: return "unmute"
        }
    }
}

struct PTZRequestSetVolume: PTZRequest {
    let volume: PTZVolume
    var bytes: Bytes {
        buildBytes([0x41, 0x25], .init(volume, .index(3)), .init(volume, .index(4)), .init(volume, .index(5)))
    }
    var description: String { "Set volume to \(volume.description)" }
}

struct PTZRequestGetVolume: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x25]) }
    var description: String { "Get volume" }
}

struct PTZReplyVolume: PTZReply {
    let volume: PTZVolume
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x25]) else { return nil }
        self.volume = message.parseArgument(position: .index(3))
    }
    
    var description: String {
        return "Volume(\(volume.description))"
    }
}
