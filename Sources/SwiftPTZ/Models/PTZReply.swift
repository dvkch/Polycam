//
//  PTZReply.swift
//
//
//  Created by syan on 30/12/2023.
//

import Foundation

struct PTZReply {
    init(bytes: [UInt8]) {
        self.bytes = bytes
    }
    let bytes: [UInt8]
}

extension PTZReply {
    init(string: String) {
        self.init(bytes: string.bytes)
    }
    var stringRepresentation: String {
        return bytes.stringRepresentation
    }
    var validLength: Bool {
        let messageLength = bytes.count - 1
        let expectedLength = (bytes.first ?? 0x80) & 0x0F
        return messageLength == expectedLength
    }
}

enum PTZReplyParsed {
    case ack
    case executed
    case notExecutedSyntaxError
    case position(pan: PTZPosition, tilt: PTZPosition, zoom: PTZPosition)
}
extension PTZReply {
    var parsed: PTZReplyParsed {
        if stringRepresentation == "A0" {
            return .ack
        }
        else if stringRepresentation == "92 40 00" {
            return .executed
        }
        else if stringRepresentation == "93 40 01 10" {
            return .notExecutedSyntaxError
        }
        else if stringRepresentation.starts(with: "8A 41 50") {
            let pan  = UInt16(from: bytes, loIndex: 5, hiIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x02)
            let tilt = UInt16(from: bytes, loIndex: 7, hiIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x08)
            let zoom = UInt16(from: bytes, loIndex: 9, hiIndex: 8, loRetainerIndex: 3, loRetainerMask: 0x20)
            return .position(pan: .init(kind: .pan, value: pan), tilt: .init(kind: .tilt, value: tilt), zoom: .init(kind: .zoom, value: zoom))
        }
        else {
            fatalError("Unknown reply: \(stringRepresentation)")
        }
    }
}

