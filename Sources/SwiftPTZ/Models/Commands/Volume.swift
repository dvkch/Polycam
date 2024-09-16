//
//  Volume.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

#warning("Should be either 080808 or 0F0003")
#warning("TODO: check if there is sound over HDMI")

struct PTZVolume: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int { 0 }
    static var maxValue: Int { 0x0F }
    static var ptzOffset: Int { 0 }
    static var ptzScale: Double { 1 }
    static var `default`: PTZVolume { .init(rawValue: 0x08) }
}

struct PTZRequestSetVolume: PTZRequest {
    let volume: PTZVolume
    var bytes: Bytes {
        buildBytes([0x41, 0x25], .init(volume, .raw8(3)), .init(volume, .raw8(4)), .init(volume, .raw8(5)))
    }
    var description: String { "Set volume to \(volume.rawValue)" }
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
        self.volume = message.parseArgument(position: .raw8(3))
    }
    
    var description: String {
        return "Volume(\(volume))"
    }
}
