//
//  Tilt.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation

struct PTZTilt: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 500 // max bytes are 03 74
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZTilt { .mid }
}

struct PTZTiltOriginalAPI: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 250
    static var ptzScale: Double = 0.005
    static var `default`: PTZTiltOriginalAPI { .init(rawValue: 0) }
}

struct PTZTiltState: PTZSingleValueState {
    static var name: String = "Tilt"
    static var register: (UInt8, UInt8) = (0x03, 0x05)
    
    var value: PTZTilt
    
    init(_ value: PTZTilt) {
        self.value = value
    }
}
