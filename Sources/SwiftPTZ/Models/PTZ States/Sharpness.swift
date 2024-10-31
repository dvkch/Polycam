//
//  Sharpness.swift
//
//
//  Created by syan on 10/07/2024.
//

import Foundation

struct PTZSharpness: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 1
    static var maxValue: Int = 11
    static var ptzOffset: Int = 122
    static var ptzScale: Double = 1
    static var `default`: PTZSharpness { .init(rawValue: 6) }
}

struct PTZSharpnessState: PTZSingleValueState {
    static var name: String = "Sharpness"
    static var register: (UInt8, UInt8) = (0x03, 0x3D)
    
    var value: PTZSharpness
    
    init(_ value: PTZSharpness) {
        self.value = value
    }
}
