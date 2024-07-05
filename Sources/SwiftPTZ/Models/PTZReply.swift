//
//  PTZReply.swift
//
//
//  Created by syan on 30/12/2023.
//

import Foundation

protocol PTZReply: CustomStringConvertible {
    init?(message: PTZMessage)
}

struct PTZReplyUnknown: PTZReply {
    let bytes: Bytes

    init(message: PTZMessage) {
        self.bytes = message.bytes
    }
    
    var description: String {
        return "Unknown(\(bytes.stringRepresentation))"
    }
}

struct PTZReplyAck: PTZReply {
    init?(message: PTZMessage) {
        guard message.bytes.stringRepresentation == "A0" else { return nil }
    }
    
    var description: String {
        return "ACK"
    }
}

struct PTZReplyExecuted: PTZReply {
    init?(message: PTZMessage) {
        guard message.bytes.stringRepresentation == "92 40 00" else { return nil }
    }
    
    var description: String {
        return "Executed"
    }
}

struct PTZReplyNotExecuted: PTZReply {
    enum PTZCommandError: UInt16, RawRepresentable, CaseIterable, CustomStringConvertible, PTZValue {
        case unknown            = 0x00
        case syntaxError        = 0x10
        case commandNotDefined  = 0x12
        
        var description: String {
            switch self {
            case .unknown:           return "Unknown"
            case .syntaxError:       return "Syntax error"
            case .commandNotDefined: return "Command not defined"
            }
        }
    }
    
    let error: PTZCommandError

    init?(message: PTZMessage) {
        guard message.bytes.stringRepresentation.starts(with: "93 40 01") else { return nil }
        self.error = message.parseArgument(position: .index(3))
    }
    
    var description: String {
        return "Not executed: \(error.description)"
    }
}
