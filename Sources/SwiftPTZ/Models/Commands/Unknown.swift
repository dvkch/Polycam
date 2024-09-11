//
//  Unknown.swift
//
//
//  Created by syan on 30/07/2024.
//

import Foundation

struct PTZUnknownRequest: PTZRequest {
    let commandBytes: Bytes
    let arg: Int?
    var bytes: Bytes {
        if let arg {
            return buildBytes(commandBytes, .init(PTZInt(rawValue: arg), .single))
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
