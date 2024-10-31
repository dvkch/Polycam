//
//  Contrast.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation

struct PTZContrast: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 20
    static var ptzOffset: Int = 118
    static var ptzScale: Double = 1
    static var `default`: PTZContrast { .init(rawValue: 10) }
}

struct PTZContrastState: PTZSingleValueState {
    static var name: String = "Contrast"
    static var register: (UInt8, UInt8) = (0x01, 0x32)

    var value: PTZContrast
    
    init(_ value: PTZContrast) {
        self.value = value
    }
}
