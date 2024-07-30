//
//  StandbyMode.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

#warning("try sending 00 00 00 00 to wake up")
enum PTZStandbyMode: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    #warning("try 0x02")
    case on  = 0x12
    case off = 0x10
    
    var description: String {
        switch self {
        case .on:   return "on"
        case .off:  return "off"
        }
    }
    
    static var `default`: PTZStandbyMode { .off }
}

struct PTZRequestSetStandbyMode: PTZRequest {
    let mode: PTZStandbyMode
    var bytes: Bytes { buildBytes([0x41, 0x00], mode) }
    var description: String { "Set standby mode \(mode.description)" }
    var waitingTimeIfExecuted: TimeInterval {
        return mode == .on ? 5 : 0
    }
}

struct PTZRequestGetStandbyMode: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x00]) }
    var description: String { "Get standby mode" }
}

struct PTZReplyStandbyMode: PTZReply {
    let mode: PTZStandbyMode

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x00]) else { return nil }
        self.mode = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "StandbyMode(\(mode.description))"
    }
}
