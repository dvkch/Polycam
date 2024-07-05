//
//  PTZReply.swift
//
//
//  Created by syan on 30/12/2023.
//

import Foundation

protocol PTZReply: CustomStringConvertible {
    init?(message: PTZMessage)
}

struct PTZReplyUnknown: PTZReply {
    let bytes: Bytes

    init(message: PTZMessage) {
        self.bytes = message.bytes
    }
    
    var description: String {
        return "Unknown(\(bytes.stringRepresentation))"
    }
}

struct PTZReplyAck: PTZReply {
    init?(message: PTZMessage) {
        guard message.bytes.stringRepresentation == "A0" else { return nil }
    }
    
    var description: String {
        return "ACK"
    }
}

struct PTZReplyExecuted: PTZReply {
    init?(message: PTZMessage) {
        guard message.bytes.stringRepresentation == "92 40 00" else { return nil }
    }
    
    var description: String {
        return "Executed"
    }
}

struct PTZReplyNotExecuted: PTZReply {
    init?(message: PTZMessage) {
        guard message.bytes.stringRepresentation == "93 40 01 10" else { return nil }
    }
    
    var description: String {
        return "Not executed: syntax error"
    }
}

struct PTZReplyPosition: PTZReply {
    let pan: PTZPositionPan
    let tilt: PTZPositionTilt
    let zoom: PTZPositionZoom
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x50]) else { return nil }
        self.pan  = message.parseArgument(position: .custom(hiIndex: 4, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02))
        self.tilt = message.parseArgument(position: .custom(hiIndex: 6, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08))
        self.zoom = message.parseArgument(position: .custom(hiIndex: 8, loIndex: 9, loRetainerIndex: 3, loRetainerMask: 0x20))
    }
    
    var description: String {
        return "Position(\(pan.rawValue), \(tilt.rawValue), \(zoom.rawValue))"
    }
}

struct PTZReplyBrightness: PTZReply {
    let brightness: PTZBrightness
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x33]) else { return nil }
        self.brightness = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "Brightness(\(brightness.rawValue))"
    }
}

/*
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: rx: read response 49 bytes: 8f 30 46 77 06 30 31 30 30 30 30 35 37 30 31 30 31 30 30 35 32 30 31 30 30 30 30 32 31 30 31 30 30 30 30 30 36 32 39 35 30 30 31 30 31 30 30 34 38
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: MPTZ_11
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: sysver = "01000057", camver = "01010052"
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: lensver = "", promver = ""
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: backver = "01000021", bootver = "01000006"
12:35:28.338 INFO     SMan: hd[0]: CameraJCCP: ParseReadResponse: splver = "2950", pkgver = "01010048"
12:35:28.339 INFO     SMan: hd[0]: SrcMan: DiscoverCamera: Detected MPTZ_11 @ -1248683884, Port 1
 */
