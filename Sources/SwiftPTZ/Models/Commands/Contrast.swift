//
//  Contrast.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZContrast: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 20
    static var ptzOffset: Int = 118
    static var ptzScale: Double = 1
    static var `default`: PTZContrast { .init(rawValue: 10) }
}

struct PTZRequestSetContrast: PTZRequest {
    let contrast: PTZContrast
    var bytes: Bytes { buildBytes([0x41, 0x32], contrast) }
    var description: String { "Set contrast to \(contrast)" }
}

struct PTZRequestGetContrast: PTZGetRequest {
    typealias Reply = PTZReplyContrast
    var bytes: Bytes { buildBytes([0x01, 0x32]) }
    var description: String { "Get contrast" }
}

struct PTZReplyContrast: PTZSpecificReply {
    let contrast: PTZContrast
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x32]) else { return nil }
        self.contrast = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Contrast(\(contrast))"
    }
}
