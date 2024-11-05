//
//  Clock.swift
//
//
//  Created by syan on 11/09/2024.
//

import Foundation

enum PTZClock: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case clock1 = 0x5D
    case clock2 = 0x5E
    
    var description: String {
        switch self {
        case .clock1: return "t1"
        case .clock2: return "t2"
        }
    }
    
    static var `default`: PTZClock { .clock1 }
}

#warning("Simplify the encoding/decoding")
struct PTZClockState: PTZReadable, PTZWriteable {
    static let name = "Clock"

    var variant: PTZClock
    var value: UInt32
    
    init(_ value: UInt32, for variant: PTZClock) {
        self.variant = variant
        self.value = value
    }

    init?(message: PTZMessage) {
        guard let clock = PTZClock.allCases.first(where: { message.isValidReply((0x41, UInt8($0.rawValue))) }) else { return nil }

        let timePart0: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08))
        let timePart1: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x04))
        let timePart2: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02))
        let timePart3: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x01))

        self.variant = clock
        self.value = (
            (UInt32(timePart0.rawValue) <<  0) +
            (UInt32(timePart1.rawValue) <<  8) +
            (UInt32(timePart2.rawValue) << 16) +
            (UInt32(timePart3.rawValue) << 24)
        )
    }
    
    func set() -> PTZRequest {
        let timePart0 = UInt16( value        & 0xFF)
        let timePart1 = UInt16((value >>  8) & 0xFF)
        let timePart2 = UInt16((value >> 16) & 0xFF)
        let timePart3 = UInt16((value >> 24) & 0xFF)
        let message = PTZMessage(
            (0x41, UInt8(variant.rawValue)),
            .init(PTZUInt(rawValue: timePart0), .custom(hiIndex: 13, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08)),
            .init(PTZUInt(rawValue: timePart1), .custom(hiIndex: 13, loIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x04)),
            .init(PTZUInt(rawValue: timePart2), .custom(hiIndex: 13, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02)),
            .init(PTZUInt(rawValue: timePart3), .custom(hiIndex: 13, loIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x01))
        )
        return .init(name: "Set \(description)", message: message)
    }
    
    static func get(for variant: Variant) -> PTZRequest {
        return .init(name: name, message: .init((0x01, UInt8(variant.rawValue))))
    }
}
