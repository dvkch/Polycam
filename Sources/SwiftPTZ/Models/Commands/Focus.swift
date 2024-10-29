//
//  Focus.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation

struct PTZFocus: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 240
    static var maxValue: Int = 768 // max bytes are 06 00
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZFocus { .init(rawValue: 0) }
}

struct PTZRequestStartFocus: PTZRequest {
    var bytes: Bytes { buildBytes([0x45, 0x13]) }
    var description: String { "Start focus" } // takes about 5s to settle down
}

struct PTZRequestSetFocus: PTZRequest {
    let focus: PTZFocus
    var bytes: Bytes { buildBytes([0x43, 0x03], focus) }
    var description: String { "Set focus to \(focus)" }
    var modeConditionRescueRequests: [any PTZRequest]? { [PTZRequestSetAutoFocus(enabled: .off)] } /* setting mire mode to True also works */
}

struct PTZRequestGetFocus: PTZGetRequest {
    typealias Reply = PTZReplyFocus
    var bytes: Bytes { buildBytes([0x03, 0x03]) }
    var description: String { "Get focus" }
}

struct PTZReplyFocus: PTZReply {
    let focus: PTZFocus
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x03]) else { return nil }
        self.focus = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Focus(\(focus))"
    }
}
