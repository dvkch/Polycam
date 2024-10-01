//
//  Unknown.swift
//
//
//  Created by syan on 30/07/2024.
//

import Foundation

struct PTZRawRequest: PTZRequest {
    var bytes: Bytes
    var description: String { "Raw request: \(bytes.stringRepresentation)" }
}

struct PTZUnknownRequest: PTZRequest {
    let commandBytes: Bytes
    let arg: UInt16?
    var bytes: Bytes {
        if let arg {
            return buildBytes(commandBytes, .init(PTZUInt(rawValue: arg), .single))
        }
        return buildBytes(commandBytes)
    }
    var description: String { "Unknown request: \(bytes.stringRepresentation)" }
}

struct PTZReplyUnknown: PTZReply {
    let bytes: Bytes
    init(message: PTZMessage) { self.bytes = message.bytes }
    var description: String { return "Unknown(\(bytes.stringRepresentation))" }
}
