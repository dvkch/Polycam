//
//  Led.swift
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

struct PTZLedState: PTZInvariantState {
    static var name: String = "Led"
    static var register: (UInt8, UInt8) = (0x01, 0x21)
    
    struct Value: Equatable {
        var color: PTZLedColor
        var mode: PTZLedMode
    }
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    init?(message: PTZMessage) {
        guard message.isValidReply([Self.register.0 + 0x40, Self.register.1]) else { return nil }
        self.value = .init(
            color: message.parseArgument(position: .raw8(3)),
            mode: message.parseArgument(position: .raw8(4))
        )
    }
    
    func set() -> any PTZRequest {
        return PTZStateRequest(
            name: "Set \(description)",
            message: .init([Self.register.0 + 0x40, Self.register.1], .init(value.color, .raw8(3)), .init(value.mode, .raw8(4)))
        )
    }
    
    var description: String { "\(Self.name)(\(value.color), \(value.mode))" }
}
