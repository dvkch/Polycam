//
//  Led.swift
//  PTZ
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public enum PTZLedColor: UInt16, PTZEnumValue {
    case off    = 0x00
    case green  = 0x01
    case blue   = 0x02
    case cyan   = 0x03
    case red    = 0x04
    case yellow = 0x05
    case purple = 0x06
    case white  = 0x07
    
    public var description: String {
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
    
    public static let `default`: Self = .blue
}

public enum PTZLedMode: UInt16, PTZEnumValue {
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
    
    public var description: String {
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
    
    public static let `default`: Self = .on
}

/// Controls the front led's color and on/off/blink state
/// Discovered in the original application's log, extended through fuzzing
public struct PTZLed: Equatable, CustomStringConvertible, CLIDecodable, JSONEncodable {
    public let color: PTZLedColor
    public let mode: PTZLedMode
    public var description: String { "\(color), \(mode)" }
    
    public init(color: PTZLedColor, mode: PTZLedMode) {
        self.color = color
        self.mode = mode
    }

    public init?(from cliString: String) {
        let parts = cliString.split(separator: ",")
        guard parts.count == 2 else { return nil }
        
        guard let color = PTZLedColor(from: String(parts[0])), let mode = PTZLedMode(from: String(parts[1])) else { return nil }
        self.color = color
        self.mode = mode
    }
    
    public static var cliStringExamples: [String] {
        return ["color,mode"]
    }
    
    public var toJSON: JSONValue {
        return ["color": color.toJSON, "mode": mode.toJSON]
    }
}

public struct PTZLedState: PTZReadable, PTZWritable {
    public static let name: String = "Led"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x21)
    
    public var value: PTZLed
    
    public init(_ value: PTZLed, for variant: PTZNone) {
        self.value = value
    }
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.register.set()) else { return nil }
        self.value = .init(
            color: message.parseArgument(position: .raw8(3)),
            mode: message.parseArgument(position: .raw8(4))
        )
    }
    
    public func setMessage() -> PTZMessage {
        .init(Self.register.set(), .init(value.color, .raw8(3)), .init(value.mode, .raw8(4)))
    }
}
