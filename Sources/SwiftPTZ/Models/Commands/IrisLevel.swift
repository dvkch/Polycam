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
    static var maxValue: Int = 255
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZIrisLevel { .init(rawValue: 0) }
}

struct PTZRequestSetIrisLevel: PTZRequest {
    let irisLevel: PTZIrisLevel
    var bytes: Bytes { buildBytes([0x43, 0x00], irisLevel) }
    var description: String { "Set iris level to \(irisLevel)" }
    var modeConditionRescueRequests: [any PTZRequest] { [
        PTZRequestSetAutoExposure(enabled: .off),
        PTZRequestSetGainMode(gain: .gain0dB),
        PTZRequestSetBacklightCompensation(enabled: .off)
    ] }
}

struct PTZRequestGetIrisLevel: PTZGetRequest {
    typealias Reply = PTZReplyIrisLevel
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
        return "IrisLevel(\(irisLevel))"
    }
}
