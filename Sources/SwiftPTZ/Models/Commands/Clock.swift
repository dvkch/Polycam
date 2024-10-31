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
        case .clock1: return "Clock 1"
        case .clock2: return "Clock 2"
        }
    }
    
    static var `default`: PTZClock { .clock1 }
}

struct PTZRequestSetClock: PTZRequest {
    let clock: PTZClock
    let time: UInt32
    var message: PTZMessage {
        let timePart0 = UInt16( time        & 0xFF)
        let timePart1 = UInt16((time >>  8) & 0xFF)
        let timePart2 = UInt16((time >> 16) & 0xFF)
        let timePart3 = UInt16((time >> 24) & 0xFF)
        return .init(
            [0x41, UInt8(clock.rawValue)],
            .init(PTZUInt(rawValue: timePart0), .custom(hiIndex: 13, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08)),
            .init(PTZUInt(rawValue: timePart1), .custom(hiIndex: 13, loIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x04)),
            .init(PTZUInt(rawValue: timePart2), .custom(hiIndex: 13, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02)),
            .init(PTZUInt(rawValue: timePart3), .custom(hiIndex: 13, loIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x01))
        )
    }
    var description: String { "Set \(clock) to \(time)" }
}


struct PTZRequestGetClock: PTZGetRequest {
    typealias Reply = PTZReplyClock
    let clock: PTZClock
    var message: PTZMessage { .init([0x01, UInt8(clock.rawValue)]) }
    var description: String { return "Get \(clock)" }
}

struct PTZReplyClock: PTZSpecificReply {
    
    let clock: PTZClock
    let time: UInt32
    
    init?(message: PTZMessage) {
        guard let clock = PTZClock.allCases.first(where: { message.isValidReply([0x41, UInt8($0.rawValue)]) }) else { return nil }

        let timePart0: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08))
        let timePart1: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x04))
        let timePart2: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02))
        let timePart3: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x01))

        self.clock = clock
        self.time = (
            (UInt32(timePart0.rawValue) <<  0) +
            (UInt32(timePart1.rawValue) <<  8) +
            (UInt32(timePart2.rawValue) << 16) +
            (UInt32(timePart3.rawValue) << 24)
        )
    }
    
    var description: String {
        return "\(clock) (t=\(time))"
    }
}
