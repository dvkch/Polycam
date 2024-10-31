//
//  Unknown.swift
//
//
//  Created by syan on 30/07/2024.
//

import Foundation

struct PTZRawRequest: PTZRequest {
    var bytes: Bytes
    var description: String { "Raw request: \(bytes.hexString)" }
    var message: PTZMessage { .init(bytes) }
}

struct PTZUnknownRequest: PTZRequest {
    let commandBytes: Bytes
    let arg: UInt16?
    var message: PTZMessage {
        if let arg {
            return .init(commandBytes, .init(PTZUInt(rawValue: arg), .single))
        }
        return .init(commandBytes)
    }
    var description: String { "Unknown(\(message.bytes.hexString))" }
}
