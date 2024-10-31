//
//  Brightness.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZBrightness: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 20
    static var ptzOffset: Int = 117
    static var ptzScale: Double = 1
    static var `default`: PTZBrightness { .init(rawValue: 11) }
}

struct PTZBrightnessState: PTZSingleValueState {
    static var name: String = "Brightness"
    static var register: (UInt8, UInt8) = (0x01, 0x33)

    var value: PTZBrightness
    
    init(_ value: PTZBrightness) {
        self.value = value
    }
}
