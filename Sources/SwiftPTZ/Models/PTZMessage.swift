//
//  File.swift
//  
//
//  Created by syan on 03/07/2024.
//

import Foundation

struct PTZMessage {
    static func messages(from bytes: Bytes) -> [PTZMessage] {
        return bytes
            .split(startFilter: { $0 >= 0x80 })
            .map { self.init(bytes: $0) }
    }
    
    let bytes: Bytes

    private init(bytes: Bytes) {
        self.bytes = bytes
    }
}

extension PTZMessage {
    var isValidLength: Bool {
        let expectedLength = (bytes.first ?? 0x80) & 0x0F
        return messageLength == expectedLength
    }
    
    var messageLength: Int {
        return bytes.count - 1
    }
    
    func isValidReply(_ command: Bytes) -> Bool {
        guard isValidLength && messageLength >= 2 else { return false }
        return Array(bytes[1..<3]) == command
    }
}

extension PTZMessage {
    func parseOnlyArgument<V: PTZValue>(type: V.Type) -> V {
        if bytes.count == 4 {
            return V.init(ptzValue: UInt16(bytes[3]))
        }
        if bytes.count == 5 {
            return V.init(ptzValue: UInt16(bytes[3]) + 0x7F + UInt16(bytes[4]))
        }
        fatalError("There is no first argument here")
    }
    
    func parseArgument<V: PTZValue>(type: V.Type, hiIndex: Int, loIndex: Int, loRetainerIndex: Int, loRetainerMask: Byte) -> V {
        return V.init(from: bytes, loIndex: loIndex, hiIndex: hiIndex, loRetainerIndex: loRetainerIndex, loRetainerMask: loRetainerMask)
    }
}

extension PTZMessage {
    static var availableReplies: [any PTZReply.Type] {
        return [PTZReplyAck.self, PTZReplyExecuted.self, PTZReplyNotExecuted.self, PTZReplyPosition.self, PTZReplyBrightness.self]
    }
    
    static func replies(from bytes: Bytes, allowed: [any PTZReply.Type] = availableReplies) -> [any PTZReply] {
        let messages = PTZMessage.messages(from: bytes)
        return messages.map { message in
            allowed.compactMap({ $0.init(message: message) }).first ?? PTZReplyUnknown(message: message)
        }
    }

}
