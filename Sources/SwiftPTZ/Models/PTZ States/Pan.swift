//
//  Pan.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation

struct PTZPan: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 2000 // max bytes are 0F 50
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZPan { .mid }
}

struct PTZPanOriginalAPI: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 1_000
    static var ptzScale: Double = 0.02
    static var `default`: PTZPanOriginalAPI { .init(rawValue: 0) }
}

struct PTZRequestSetPan: PTZRequest {
    let pan: PTZPan
    var message: PTZMessage { .init([0x43, 0x04], pan) }
    var description: String { "Set pan to \(pan)" }
}

struct PTZRequestGetPan: PTZGetRequest {
    typealias Reply = PTZReplyPan
    var message: PTZMessage { .init([0x03, 0x04]) }
    var description: String { "Get pan" }
}

struct PTZReplyPan: PTZSpecificReply {
    let pan: PTZPan
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x04]) else { return nil }
        self.pan = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Pan(\(pan))"
    }
}
