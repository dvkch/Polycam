//
//  Preset.swift
//  SwiftPTZ
//
//  Created by syan on 30/09/2024.
//

import Foundation
import PTZMessaging

#warning("make simplified command to use those (save current position to preset, set current position to preset)")
public enum PTZPreset: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case one    = 0x00
    case two    = 0x01
    case three  = 0x02
    case four   = 0x03
    case five   = 0x04
    case six    = 0x05
    case seven  = 0x06
    case eight  = 0x07
    
    public var description: String {
        switch self {
        case .one:      return "one"
        case .two:      return "two"
        case .three:    return "three"
        case .four:     return "four"
        case .five:     return "five"
        case .six:      return "six"
        case .seven:    return "seven"
        case .eight:    return "eight"
        }
    }
}

public struct PTZPresetState: PTZState, PTZReadable, PTZWriteable {
    public static var name: String = "Preset"
    
    public var variant: PTZPreset
    public var value: PTZPosition
    
    public init(_ value: PTZPosition, for variant: PTZPreset) {
        self.value = value
        self.variant = variant
    }
    
    public init?(message: PTZMessage) {
        guard let preset = PTZPreset.allCases.first(where: { message.isValidReply((0x41, 0x60 + UInt8($0.rawValue))) }) else { return nil }
        self.variant = preset
        self.value = .init(
            pan:  message.parseArgument(position: .custom(hiIndex: 4, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02)),
            tilt: message.parseArgument(position: .custom(hiIndex: 6, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08)),
            zoom: message.parseArgument(position: .custom(hiIndex: 8, loIndex: 9, loRetainerIndex: 3, loRetainerMask: 0x20))
        )
    }
    
    public func setMessage() -> PTZMessage {
        return .init(
            (0x41, 0x60 + UInt8(variant.rawValue)),
            PTZArgument(value.pan,  .custom(hiIndex:  5, loIndex:  6, loRetainerIndex:  3, loRetainerMask: 0x04)),
            PTZArgument(value.tilt, .custom(hiIndex:  8, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20)),
            PTZArgument(value.zoom, .custom(hiIndex: 12, loIndex: 13, loRetainerIndex: 11, loRetainerMask: 0x02)),
            PTZArgument(PTZUInt(rawValue: 0x03), .raw8(10))
        )
    }
    
    public static func get(for variant: PTZPreset) -> PTZRequest {
        return .init(name: name, message: .init((0x01, 0x60 + UInt8(variant.rawValue))))
    }
}
