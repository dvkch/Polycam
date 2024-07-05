//
//  LedMode.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZLedMode: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    #warning("TODO: should be sent on 2 bytes always....")
    case on  = 0x0000
    case off = 0x0210
    case unknown = 0x007F

    var description: String {
        switch self {
        case .on:   return "on"
        case .off:  return "off"
        case .unknown: return "unknown" 
        }
    }
}

struct PTZRequestSetLedMode: PTZRequest {
    let mode: PTZLedMode
    var bytes: Bytes { buildBytes([0x41, 0x21], mode) }
    var description: String { "Set LED \(mode.description)" }
}

struct PTZRequestGetLedMode: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x21]) }
    var description: String { "Get LED" }
}

struct PTZReplyLedMode: PTZReply {
    let mode: PTZLedMode
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x21]) else { return nil }
        self.mode = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "LedMode(\(mode.description))"
    }
}
