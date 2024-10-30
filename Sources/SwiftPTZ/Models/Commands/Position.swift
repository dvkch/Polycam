//
//  Position.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZRequestSetPosition: PTZRequest {
    let pan: PTZPan
    let tilt: PTZTilt
    let zoom: PTZZoom
    
    var bytes: Bytes {
        return buildBytes(
            [0x41, 0x51],
            PTZArgument(pan,  .custom(hiIndex:  5, loIndex:  6, loRetainerIndex:  3, loRetainerMask: 0x04)),
            PTZArgument(tilt, .custom(hiIndex:  8, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20)),
            PTZArgument(zoom, .custom(hiIndex: 12, loIndex: 13, loRetainerIndex: 11, loRetainerMask: 0x02)),
            PTZArgument(PTZUInt(rawValue: 0x03), .raw8(10))
        )
    }
    
    var description: String { "Move to \(pan), \(tilt), \(zoom)" }
}

struct PTZRequestGetPosition: PTZGetRequest {
    typealias Reply = PTZReplyPosition
    var bytes: Bytes { buildBytes([0x01, 0x50]) }
    var description: String { "Get position" }
}

struct PTZReplyPosition: PTZReply {
    let pan: PTZPan
    let tilt: PTZTilt
    let zoom: PTZZoom
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x50]) else { return nil }
        self.pan  = message.parseArgument(position: .custom(hiIndex: 4, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02))
        self.tilt = message.parseArgument(position: .custom(hiIndex: 6, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08))
        self.zoom = message.parseArgument(position: .custom(hiIndex: 8, loIndex: 9, loRetainerIndex: 3, loRetainerMask: 0x20))
    }
    
    var description: String {
        return "Position(\(pan), \(tilt), \(zoom))"
    }
}
