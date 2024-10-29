//
//  WhiteBalanceTint.swift
//  SwiftPTZ
//
//  Created by syan on 22/09/2024.
//

#warning("confirm min/max")
struct PTZWhiteBalanceTint: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 95
    static var maxValue: Int = 160
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZWhiteBalanceTint { .init(rawValue: 128) }
}

struct PTZRequestSetWhiteBalanceTint: PTZRequest {
    let tint: PTZWhiteBalanceTint
    var bytes: Bytes { buildBytes([0x43, 0x40], tint) }
    var description: String { "Set wb tint to \(tint)" }
    #warning("set up all mode conditions rescues for all requests")
}

struct PTZRequestGetWhiteBalanceTint: PTZGetRequest {
    typealias Reply = PTZReplyWhiteBalanceTint
    var bytes: Bytes { buildBytes([0x03, 0x40]) }
    var description: String { "Get wb tint" }
}

struct PTZReplyWhiteBalanceTint: PTZReply {
    let tint: PTZWhiteBalanceTint
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x40]) else { return nil }
        self.tint = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "WBTint(\(tint))"
    }
}

