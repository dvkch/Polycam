//
//  PTZReply.swift
//
//
//  Created by syan on 30/12/2023.
//

import Foundation

struct PTZReply {
    let bytes: Bytes
    init(bytes: Bytes) {
        self.bytes = bytes
    }
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

enum PTZReplyParsed: Equatable {
    case ack
    case executed
    case notExecutedSyntaxError
    case position(pan: PTZPosition, tilt: PTZPosition, zoom: PTZPosition)
    
    /*
    12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: rx: read response 49 bytes: 8f 30 46 77 06 30 31 30 30 30 30 35 37 30 31 30 31 30 30 35 32 30 31 30 30 30 30 32 31 30 31 30 30 30 30 30 36 32 39 35 30 30 31 30 31 30 30 34 38
    12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: MPTZ_11
    12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: sysver = "01000057", camver = "01010052"
    12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: lensver = "", promver = ""
    12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: backver = "01000021", bootver = "01000006"
    12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: splver = "2950", pkgver = "01010048"
    12:35:28.339 INFO     SMan: hd[0]: SrcMan: DiscoverCamera: Detected MPTZ_11 @ -1248683884, Port 1
     */
    //case hello()
}
extension PTZReply {
    var parsed: PTZReplyParsed? {
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
            return nil
        }
    }
}

