//
//  VideoOutput.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZVideoOutputMode: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case unknown00         = 0x00
    case unknown0A         = 0x0a
    case resolution720p60  = 0x10
    case resolution1080p60 = 0x1a
    
    var description: String {
        switch self {
        case .unknown00:         return "Unknown(00)"
        case .unknown0A:         return "Unknown(0A)"
        case .resolution720p60:  return "720p60"
        case .resolution1080p60: return "1080p60"
        }
    }
    
    static var `default`: PTZVideoOutputMode { .resolution1080p60 }
}

struct PTZRequestSetVideoOutputMode: PTZRequest {
    let mode: PTZVideoOutputMode
    var message: PTZMessage { .init([0x41, 0x13], mode) }
    var description: String { "Set video output \(mode.description)" }
    var waitingTimeIfExecuted: TimeInterval { 6 }
}

struct PTZRequestGetVideoOutputMode: PTZGetRequest {
    typealias Reply = PTZReplyVideoOutputMode
    var message: PTZMessage { .init([0x01, 0x13]) }
    var description: String { "Get video output" }
}

struct PTZReplyVideoOutputMode: PTZSpecificReply {
    let mode: PTZVideoOutputMode

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x13]) else { return nil }
        self.mode = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "VideoOutputMode(\(mode.description))"
    }
}
