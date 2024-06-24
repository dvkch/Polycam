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
    case brightness(brightness: PTZBrightness)
    case unknown(bytes: Bytes)
    
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

extension PTZReplyParsed: CustomStringConvertible {
    var description: String {
        switch self {
        case .ack:
            return "ACK"
        case .executed:
            return "Executed"
        case .notExecutedSyntaxError:
            return "Not executed: syntax error"
        case .position(let pan, let tilt, let zoom):
            return "Position(\(pan.value), \(tilt.value), \(zoom.value))"
        case .brightness(let brightness):
            return "Brightness(\(brightness.value))"
        case .unknown(let bytes):
            return "Unknown(\(bytes.stringRepresentation))"
        }
    }
}


extension PTZReply {
    func replies() -> [PTZReplyParsed] {
        var replies = [PTZReplyParsed]()
        
        var startIndex = 0
        var endIndex = 0
        
        while startIndex < bytes.count {
            while endIndex < bytes.count {
                if let parsed = PTZReply(bytes: Array(bytes[startIndex...endIndex])).reply() {
                    replies.append(parsed)
                    startIndex = endIndex + 1
                    endIndex += 1
                }
                else {
                    endIndex += 1
                }
            }
            startIndex += 1
        }
        return replies
    }

    private func reply() -> PTZReplyParsed? {
        if stringRepresentation == "A0" {
            return .ack
        }
        else if stringRepresentation == "92 40 00" {
            return .executed
        }
        else if stringRepresentation == "93 40 01 10" {
            return .notExecutedSyntaxError
        }
        else if stringRepresentation.starts(with: "8A 41 50") && validLength {
            let pan  = UInt16(from: bytes, loIndex: 5, hiIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x02)
            let tilt = UInt16(from: bytes, loIndex: 7, hiIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x08)
            let zoom = UInt16(from: bytes, loIndex: 9, hiIndex: 8, loRetainerIndex: 3, loRetainerMask: 0x20)
            return .position(pan: .init(kind: .pan, value: pan), tilt: .init(kind: .tilt, value: tilt), zoom: .init(kind: .zoom, value: zoom))
        }
        else if stringRepresentation.starts(with: "83 41 33") && validLength {
            return .brightness(brightness: .init(value: Int(bytes[3] - 0x75)))
        }
        else if stringRepresentation.starts(with: "84 41 33 01") && validLength {
            return .brightness(brightness: .init(value: Int(bytes[4] + 11)))
        }
        else if validLength {
            return .unknown(bytes: bytes)
        }
        else {
            return nil
        }
    }
}

