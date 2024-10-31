//
//  PowerMode.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZPowerMode: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case on         = 0x00
    case sleeping   = 0x02
    case standby    = 0x10
    case off        = 0x12 // it is not possible to restart the camera programmatically from that point!

    var description: String {
        switch self {
        case .on:       return "on"
        case .sleeping: return "sleeping"
        case .standby:  return "standby"
        case .off:      return "off"
        }
    }
    
    static var `default`: PTZPowerMode { .off }
}

struct PTZRequestSetPowerMode: PTZRequest {
    let mode: PTZPowerMode
    var bytes: Bytes { buildBytes([0x41, 0x00], mode) }
    var description: String { "Set power \(mode.description)" }
    var waitingTimeIfExecuted: TimeInterval {
        return mode == .on ? 5 : 0
    }
}

struct PTZRequestGetPowerMode: PTZGetRequest {
    typealias Reply = PTZReplyPowerMode
    var bytes: Bytes { buildBytes([0x01, 0x00]) }
    var description: String { "Get power mode" }
}

struct PTZReplyPowerMode: PTZSpecificReply {
    let mode: PTZPowerMode

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x00]) else { return nil }
        self.mode = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "PowerMode(\(mode.description))"
    }
}
