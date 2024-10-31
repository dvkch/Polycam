//
//  Preset.swift
//  SwiftPTZ
//
//  Created by syan on 30/09/2024.
//

#warning("make simplified command to use those (save current position to preset, set current position to preset)")
enum PTZPreset: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case one    = 0x00
    case two    = 0x01
    case three  = 0x02
    case four   = 0x03
    case five   = 0x04
    case six    = 0x05
    case seven  = 0x06
    case eight  = 0x07
    
    var description: String {
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
    
    static var `default`: PTZPreset { .one }
}

struct PTZRequestSetPreset: PTZRequest {
    let preset: PTZPreset
    let pan: PTZPan
    let tilt: PTZTilt
    let zoom: PTZZoom
    
    var message: PTZMessage {
        return .init(
            [0x41, 0x60 + UInt8(preset.rawValue)],
            PTZArgument(pan,  .custom(hiIndex:  5, loIndex:  6, loRetainerIndex:  3, loRetainerMask: 0x04)),
            PTZArgument(tilt, .custom(hiIndex:  8, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20)),
            PTZArgument(zoom, .custom(hiIndex: 12, loIndex: 13, loRetainerIndex: 11, loRetainerMask: 0x02)),
            PTZArgument(PTZUInt(rawValue: 0x03), .raw8(10))
        )
    }
    
    var description: String { "Set preset \(preset) to \(pan), \(tilt), \(zoom)" }
}

struct PTZRequestGetPreset: PTZGetRequest {
    typealias Reply = PTZReplyPreset
    let preset: PTZPreset
    var message: PTZMessage { .init([0x01, 0x60 + UInt8(preset.rawValue)]) }
    var description: String { "Get preset \(preset)" }
}

struct PTZReplyPreset: PTZSpecificReply {
    let preset: PTZPreset
    let pan: PTZPan
    let tilt: PTZTilt
    let zoom: PTZZoom
    
    init?(message: PTZMessage) {
        guard let preset = PTZPreset.allCases.first(where: { message.isValidReply([0x41, 0x60 + UInt8($0.rawValue)]) }) else { return nil }
        self.preset = preset
        self.pan  = message.parseArgument(position: .custom(hiIndex: 4, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02))
        self.tilt = message.parseArgument(position: .custom(hiIndex: 6, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08))
        self.zoom = message.parseArgument(position: .custom(hiIndex: 8, loIndex: 9, loRetainerIndex: 3, loRetainerMask: 0x20))
    }
    
    var description: String {
        return "Preset(\(preset): \(pan), \(tilt), \(zoom))"
    }
}
