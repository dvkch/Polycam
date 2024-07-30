//
//  IrisLevel.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZIrisLevel: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 1000
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var testValues: [PTZIrisLevel] { Array(minValue...maxValue).map(Self.init(rawValue:)) }
    static var `default`: PTZIrisLevel { .init(rawValue: 0) }
}

struct PTZRequestSetIrisLevel: PTZRequest {
    let irisLevel: PTZIrisLevel
    #warning("test this out, check if the extra 0x01 is required, or if its just because we're > 0x7F")
    var bytes: Bytes { buildBytes([0x43, 0x00, 0x01], irisLevel) }
    var description: String { "Set iris level to \(irisLevel.rawValue)" }
}

struct PTZRequestGetIrisLevel: PTZRequest {
    var bytes: Bytes { buildBytes([0x03, 0x00]) }
    var description: String { "Get iris level" }
}

struct PTZReplyIrisLevel: PTZReply {
    let irisLevel: PTZIrisLevel
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x43, 0x00]) else { return nil }
        self.irisLevel = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "IrisLevel(\(irisLevel.rawValue))"
    }
}
