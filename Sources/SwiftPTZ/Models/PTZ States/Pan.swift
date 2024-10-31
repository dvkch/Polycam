//
//  Pan.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation

struct PTZPan: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 2000 // max bytes are 0F 50
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZPan { .mid }
}

struct PTZPanOriginalAPI: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = -50_000
    static var maxValue: Int =  50_000
    static var ptzOffset: Int = 1_000
    static var ptzScale: Double = 0.02
    static var `default`: PTZPanOriginalAPI { .init(rawValue: 0) }
}


struct PTZPanState: PTZSingleValueState {
    static var name: String = "Pan"
    static var register: (UInt8, UInt8) = (0x03, 0x04)
    
    var value: PTZPan
    
    init(_ value: PTZPan) {
        self.value = value
    }
}
