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

struct PTZReplyAck: PTZReply {
    init?(message: PTZMessage) { guard message.bytes == [0xA0] else { return nil } }
    var description: String { "ACK" }
}

struct PTZReplyReset: PTZReply {
    init?(message: PTZMessage) { guard message.bytes == [0xE0] else { return nil } }
    var description: String { "RESET" }
}

struct PTZReplyFail: PTZReply {
    init?(message: PTZMessage) { guard message.bytes == [0xF0] else { return nil } }
    var description: String { "FAIL" }
}

struct PTZReplyExecuted: PTZReply {
    init?(message: PTZMessage) { guard message.bytes == [0x92, 0x40, 0x00] else { return nil } }
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
        guard message.bytes.starts(with: [0x93, 0x40, 0x01]) else { return nil }
        self.error = message.parseArgument(position: .raw8(3))
    }
    
    var description: String {
        return "Not executed: \(error.description)"
    }
}
