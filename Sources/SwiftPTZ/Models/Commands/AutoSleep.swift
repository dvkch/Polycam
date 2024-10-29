//
//  AutoSleep.swift
//  SwiftPTZ
//
//  Created by syan on 29/10/2024.
//

struct PTZAutoSleepTimeout: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 1440 // 0x30 * 30min
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1/30
    static var `default`: Self { .init(rawValue: 0) }
    
    var description: String {
        guard rawValue > 0 else { return "off" }
        return String(rawValue) + "min"
    }
}

struct PTZRequestSetAutoSleep: PTZRequest {
    let timeout: PTZAutoSleepTimeout
    var bytes: Bytes { buildBytes([0x41, 0x01], timeout) }
    var description: String { "Set auto sleep to \(timeout)" }
}

struct PTZRequestGetAutoSleep: PTZGetRequest {
    typealias Reply = PTZReplyAutoSleep
    var bytes: Bytes { buildBytes([0x01, 0x01]) }
    var description: String { "Get auto sleep" }
}

struct PTZReplyAutoSleep: PTZReply {
    let timeout: PTZAutoSleepTimeout

    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x01]) else { return nil }
        self.timeout = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "AutoSleep(\(timeout))"
    }
}
