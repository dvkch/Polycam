//
//  WhiteBalanceTemp.swift
//  SwiftPTZ
//
//  Created by syan on 22/09/2024.
//

struct PTZWhiteBalanceTemp: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 96
    static var maxValue: Int = 159
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZWhiteBalanceTemp { .init(rawValue: 128) }
}

struct PTZRequestSetWhiteBalanceTemp: PTZRequest {
    let temp: PTZWhiteBalanceTemp
    var bytes: Bytes { buildBytes([0x43, 0x41], temp) }
    var description: String { "Set wb temp to \(temp)" }
    var modeConditionRescueRequests: [any PTZRequest] { [PTZRequestSetWhiteBalance(mode: .manual)] }
}

struct PTZRequestGetWhiteBalanceTemp: PTZGetRequest {
    typealias Reply = PTZReplyWhiteBalanceTemp
    var bytes: Bytes { buildBytes([0x03, 0x41]) }
    var description: String { "Get wb temp" }
}

struct PTZReplyWhiteBalanceTemp: PTZSpecificReply {
    let temp: PTZWhiteBalanceTemp
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x41]) else { return nil }
        self.temp = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "WBTemp(\(temp))"
    }
}

