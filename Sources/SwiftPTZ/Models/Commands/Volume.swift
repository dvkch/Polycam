//
//  Volume.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

#warning("Should be either 080808 or 0F0003")
#warning("TODO: check if there is sound over HDMI")

enum PTZVolume: Int, PTZValue, CaseIterable {
    #warning("maybe switch PTZValue to UInt32 backed values, to handle those better")
    init(ptzValue: UInt16) {
        fatalError("MEH")
    }
    
    var ptzValue: UInt16 {
        fatalError("MEH")
    }
    
    case `default` = 0
    case unknown1 = 1
    case unknown2 = 2

    var description: String {
        switch self {
        case .default:  return "default"
        case .unknown1: return "unknown1"
        case .unknown2: return "unknown2"
        }
    }
    
    var bytes: Bytes {
        switch self {
        case .default: return [0x08, 0x08, 0x08]
        case .unknown1: return [0x0F, 0x00, 0x03]
        case .unknown2: return [0x0F, 0x00, 0x03].reversed()
        }
    }
}

struct PTZRequestSetVolume: PTZRequest {
    let volume: PTZVolume
    var bytes: Bytes {
        buildBytes([0x41, 0x25], .init(volume.bytes[0], index8: 3), .init(volume.bytes[1], index8: 4), .init(volume.bytes[2], index8: 5))
    }
    var description: String { "Set volume to \(volume)" }
}

struct PTZRequestGetVolume: PTZGetRequest {
    typealias Reply = PTZReplyVolume
    var bytes: Bytes { buildBytes([0x01, 0x25]) }
    var description: String { "Get volume" }
}

struct PTZReplyVolume: PTZReply {
    let volume: PTZVolume
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x25]) else { return nil }
        let volumeBytes = [
            message.parseArgument(type: PTZUInt.self, position: .raw8(3)),
            message.parseArgument(type: PTZUInt.self, position: .raw8(4)),
            message.parseArgument(type: PTZUInt.self, position: .raw8(5))
        ].map { UInt8($0.rawValue) }
        self.volume = PTZVolume.allCases.first(where: { $0.bytes == volumeBytes }) ?? .default
    }
    
    var description: String {
        return "Volume(\(volume))"
    }
}
