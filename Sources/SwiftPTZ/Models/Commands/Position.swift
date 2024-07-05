//
//  Position.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZPositionPan: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 1_000
    static var ptzScale: Double = 0.02
    static var testValues: [PTZPositionPan] { Array(stride(from: minValue, to: maxValue, by: 10_000)).map(Self.init(rawValue:)) }
}

struct PTZPositionTilt: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 250
    static var ptzScale: Double = 0.005
    static var testValues: [PTZPositionTilt] { Array(stride(from: minValue, to: maxValue, by: 10_000)).map(Self.init(rawValue:)) }
}

struct PTZPositionZoom: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -49_772
    static var maxValue: Int = 17_663
    static var ptzOffset: Int = 1146
    static var ptzScale: Double = 0.021739 // <- this one is perfect match to read values, but 0.0217246 is closer to our Set fixtures
    static var testValues: [PTZPositionZoom] { Array(stride(from: minValue, to: maxValue, by: 10_000)).map(Self.init(rawValue:)) }
    // FROM: (8D 41 51 24 00 03 68 00 00 7A 03) 00 00 40
    // TO:   (8D 41 51 24 00 03 68 00 00 7A 03) 02 05 79
    // 00 40 -> 05 F9
    // 64 => 1529
}

struct PTZRequestSetPosition: PTZRequest {
    let pan: PTZPositionPan
    let tilt: PTZPositionTilt
    let zoom: PTZPositionZoom
    
    var bytes: Bytes {
        return buildBytes(
            [0x41, 0x51],
            PTZArgument(pan,  .custom(hiIndex:  5, loIndex:  6, loRetainerIndex:  3, loRetainerMask: 0x04)),
            PTZArgument(tilt, .custom(hiIndex:  8, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20)),
            PTZArgument(zoom, .custom(hiIndex: 12, loIndex: 13, loRetainerIndex: 11, loRetainerMask: 0x02)),
            PTZArgument(PTZInt(rawValue: 0x03), .index(10))
        )
    }
    
    var description: String {
        return "Move to \(pan.rawValue), \(tilt.rawValue), \(zoom.rawValue)"
    }
}

struct PTZRequestGetPosition: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x50]) }
    var description: String { "Get position" }
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
