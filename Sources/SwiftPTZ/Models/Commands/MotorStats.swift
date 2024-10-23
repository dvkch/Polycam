//
//  MotorStats.swift
//  SwiftPTZ
//
//  Created by syan on 23/10/2024.
//

// Those stats seem to count the amount of time each motor changed direction
enum PTZMotorsStats: UInt16, CaseIterable, PTZValue {
    case unknownAndNone = 0x59 // left might be camera power cycles?
    case focusAndZoom   = 0x5A
    case noneAndIris    = 0x5B
    case panAndTilt     = 0x5C

    static var `default`: PTZMotorsStats { .unknownAndNone }
    var description: String {
        "\(names.0)/\(names.1)"
    }
    fileprivate var names: (String, String) {
        switch self {
        case .unknownAndNone:   return ("Unknown", "None")
        case .focusAndZoom:     return ("Focus", "Zoom")
        case .noneAndIris:      return ("None", "Iris")
        case .panAndTilt:       return ("Pan", "Tilt")
        }
    }
}

struct PTZRequestGetMotorStats: PTZGetRequest {
    typealias Reply = PTZReplyMotorStats
    let stats: PTZMotorsStats
    var bytes: Bytes { buildBytes([0x01, UInt8(stats.rawValue)]) }
    var description: String { "Get motors stats" }
}

struct PTZReplyMotorStats: PTZReply {
    let stats: PTZMotorsStats
    let valueLeft: UInt32
    let valueRight: UInt32

    init?(message: PTZMessage) {
        guard let stats = PTZMotorsStats.allCases.first(where: { message.isValidReply([0x41, UInt8($0.rawValue)]) }) else { return nil }
        self.stats = stats
        
        let leftPart0: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08))
        let leftPart1: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x04))
        let leftPart2: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02))
        let leftPart3: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x01))
        self.valueLeft = (
            (UInt32(leftPart0.rawValue) <<  0) +
            (UInt32(leftPart1.rawValue) <<  8) +
            (UInt32(leftPart2.rawValue) << 16) +
            (UInt32(leftPart3.rawValue) << 24)
        )

        let rightPart0: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 12, loRetainerIndex: 11, loRetainerMask: 0x01))
        let rightPart1: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex: 10, loRetainerIndex:  3, loRetainerMask: 0x40))
        let rightPart2: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20))
        let rightPart3: PTZUInt = message.parseArgument(position: .custom(hiIndex: 13, loIndex:  8, loRetainerIndex:  3, loRetainerMask: 0x10))
        self.valueRight = (
            (UInt32(rightPart0.rawValue) <<  0) +
            (UInt32(rightPart1.rawValue) <<  8) +
            (UInt32(rightPart2.rawValue) << 16) +
            (UInt32(rightPart3.rawValue) << 24)
        )
    }
    var description: String {
        return "MotorStats(\(stats.names.0)=\(valueLeft), \(stats.names.1)=\(valueRight))"
    }
}
