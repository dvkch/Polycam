//
//  ShutterSpeed.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZShutterSpeed: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case zero = 0x00
    
    var description: String {
        switch self {
        case .zero: return "zero"
        }
    }
}

struct PTZRequestSetShutterSpeed: PTZRequest {
    let speed: PTZShutterSpeed
    var bytes: Bytes { buildBytes([0x42, 0x14], speed) }
    var description: String { "Set shutter speed to \(speed.description)" }
}

struct PTZRequestGetShutterSpeed: PTZRequest {
    var bytes: Bytes { buildBytes([0x02, 0x14]) }
    var description: String { "Get shutter speed" }
}

struct PTZReplyShutterSpeed: PTZReply {
    let speed: PTZShutterSpeed
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x42, 0x14]) else { return nil }
        self.speed = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "ShutterSpeed(\(speed.rawValue))"
    }
}
