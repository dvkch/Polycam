//
//  WhiteLevel.swift
//  SwiftPTZ
//
//  Created by syan on 01/10/2024.
//

import Foundation

enum PTZWhiteLevel: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case reduced = 0x5A
    case full = 0x64

    var description: String {
        switch self {
        case .reduced:  return "90%"
        case .full:     return "100%"
        }
    }
    
    static var `default`: PTZWhiteLevel { .reduced }
}

struct PTZRequestSetWhiteLevel: PTZRequest {
    let level: PTZWhiteLevel
    var message: PTZMessage { .init([0x43, 0x3F], level) }
    var description: String { "Set white level \(level.description)" }
}

struct PTZRequestGetWhiteLevel: PTZGetRequest {
    typealias Reply = PTZReplyWhiteLevel
    var message: PTZMessage { .init([0x03, 0x3F]) }
    var description: String { "Get white level" }
}

struct PTZReplyWhiteLevel: PTZSpecificReply {
    let level: PTZWhiteLevel

    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x3F]) else { return nil }
        self.level = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "WhiteLevel(\(level.description))"
    }
}
