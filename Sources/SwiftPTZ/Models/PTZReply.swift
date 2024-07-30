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
    init(message: PTZMessage) { self.bytes = message.bytes }
    var description: String { return "Unknown(\(bytes.stringRepresentation))" }
}

struct PTZReplyAck: PTZReply {
    init?(message: PTZMessage) { guard message.bytes.stringRepresentation == "A0" else { return nil } }
    var description: String { "ACK" }
}

struct PTZReplyReset: PTZReply {
    init?(message: PTZMessage) { guard message.bytes.stringRepresentation == "E0" else { return nil } }
    var description: String { "RESET" }
}

struct PTZReplyFail: PTZReply {
    init?(message: PTZMessage) { guard message.bytes.stringRepresentation == "F0" else { return nil } }
    var description: String { "FAIL" }
}

struct PTZReplyExecuted: PTZReply {
    init?(message: PTZMessage) { guard message.bytes.stringRepresentation == "92 40 00" else { return nil } }
    var description: String { return "Executed" }
}

struct PTZReplyNotExecuted: PTZReply {
    enum PTZCommandError: UInt16, RawRepresentable, CaseIterable, CustomStringConvertible, PTZValue {
        case modeCondition      = 0x00
        case panMotorWarning    = 0x01
        case tiltMotorWarning   = 0x02
        case motorsWarning      = 0x03
        case syntaxError        = 0x10
        case bufferFull         = 0x11
        case commandNotDefined  = 0x12
        case unknown            = 0xFF
        
        var description: String {
            switch self {
            case .modeCondition:     return "Mode condition"
            case .panMotorWarning:   return "Pan motor warning"
            case .tiltMotorWarning:  return "Tilt motor warning"
            case .motorsWarning:     return "Pan and tilt motors warning"
            case .syntaxError:       return "Syntax error"
            case .bufferFull:        return "Buffer full"
            case .commandNotDefined: return "Command not defined"
            case .unknown:           return "Unknown"
            }
        }
        
        static var `default`: PTZReplyNotExecuted.PTZCommandError { .bufferFull }
    }
    
    let error: PTZCommandError

    init?(message: PTZMessage) {
        guard message.bytes.stringRepresentation.starts(with: "93 40 01") else { return nil }
        self.error = message.parseArgument(position: .raw8(3))
    }
    
    var description: String {
        return "Not executed: \(error.description)"
    }
}
