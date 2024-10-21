//
//  SensorSmoothing.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZRequestSetSensorSmoothing: PTZRequest {
    let enabled: PTZBool
    var bytes: Bytes { buildBytes([0x41, 0x3B], enabled) }
    var description: String { "Set sensor smoothing \(enabled)" }
}

struct PTZRequestGetSensorSmoothing: PTZGetRequest {
    typealias Reply = PTZReplySensorSmoothing
    var bytes: Bytes { buildBytes([0x01, 0x3B]) }
    var description: String { "Get sensor smoothing" }
}

struct PTZReplySensorSmoothing: PTZReply {
    let enabled: PTZBool
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x3B]) else { return nil }
        self.enabled = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "SensorSmoothing(\(enabled))"
    }
}
