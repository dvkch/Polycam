//
//  Saturation.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZSaturation: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 11
    static var ptzOffset: Int = 122
    static var ptzScale: Double = 1
    static var `default`: PTZSaturation { .init(rawValue: 6) }
}

struct PTZSaturationState: PTZSingleValueState {
    static var name: String = "Saturation"
    static var register: (UInt8, UInt8) = (0x03, 0x3E)
    
    var value: PTZSaturation
    
    init(_ value: PTZSaturation) {
        self.value = value
    }
}
