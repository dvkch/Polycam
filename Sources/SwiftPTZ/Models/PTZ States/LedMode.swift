//
//  LedMode.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZLedColor: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case off    = 0x00
    case green  = 0x01
    case blue   = 0x02
    case cyan   = 0x03
    case red    = 0x04
    case yellow = 0x05
    case purple = 0x06
    case white  = 0x07
    
    var description: String {
        switch self {
        case .off:      return "off"
        case .green:    return "green"
        case .blue:     return "blue"
        case .cyan:     return "cyan"
        case .red:      return "red"
        case .yellow:   return "yellow"
        case .purple:   return "purple"
        case .white:    return "white"
        }
    }
    
    static var `default`: PTZLedColor { .blue }
}

enum PTZLedMode: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case off = 0x00
    case on  = 0x10
    case onceQuarterSecond  = 0x20
    case onceHalfSecond     = 0x21
    case onceOneSecond      = 0x22
    case onceTwoSeconds     = 0x23
    case onceThreeSeconds   = 0x24
    case onceFourSeconds    = 0x25
    case everyQuarterSecond = 0x30
    case everyHalfSecond    = 0x31
    case everyOneSecond     = 0x32
    case everyTwoSeconds    = 0x33
    case everyThreeSeconds  = 0x34
    case everyFourSeconds   = 0x35
    
    var description: String {
        switch self {
        case .off:                  return "off"
        case .on:                   return "on"
        case .onceQuarterSecond:    return "once 0.25s"
        case .onceHalfSecond:       return "once 0.5s"
        case .onceOneSecond:        return "once 1s"
        case .onceTwoSeconds:       return "once 2s"
        case .onceThreeSeconds:     return "once 3s"
        case .onceFourSeconds:      return "once 4s"
        case .everyQuarterSecond:   return "every 0.25s"
        case .everyHalfSecond:      return "every 0.5s"
        case .everyOneSecond:       return "every 1s"
        case .everyTwoSeconds:      return "every 2s"
        case .everyThreeSeconds:    return "every 3s"
        case .everyFourSeconds:     return "every 4s"
        }
    }
    
    static var `default`: PTZLedMode { .on }
}

struct PTZRequestSetLedMode: PTZRequest {
    let color: PTZLedColor
    let mode: PTZLedMode
    var message: PTZMessage { .init([0x41, 0x21], .init(color, .raw8(3)), .init(mode, .raw8(4))) }
    var description: String { "Set LED \(color.description) \(mode.description)" }
}

struct PTZRequestGetLedMode: PTZGetRequest {
    typealias Reply = PTZReplyLedMode
    var message: PTZMessage { .init([0x01, 0x21]) }
    var description: String { "Get LED" }
}

struct PTZReplyLedMode: PTZSpecificReply {
    let color: PTZLedColor
    let mode: PTZLedMode

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x21]) else { return nil }
        self.color = message.parseArgument(position: .raw8(3))
        self.mode  = message.parseArgument(position: .raw8(4))
    }
    
    var description: String {
        return "LedMode(\(color.description), \(mode.description))"
    }
}
