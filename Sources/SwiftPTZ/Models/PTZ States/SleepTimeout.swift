//
//  SleepTimeout.swift
//  SwiftPTZ
//
//  Created by syan on 29/10/2024.
//

struct PTZSleepTimeout: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 0
    static var maxValue: Int = 1440 // 0x30 * 30min
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1/30
    static var `default`: Self { .init(rawValue: 0) }
    
    var description: String {
        guard rawValue > 0 else { return "off" }
        return String(rawValue) + "min"
    }
}

struct PTZSleepTimeoutState: PTZSingleValueState {
    static var name: String = "SleepTimeout"
    static var register: (UInt8, UInt8) = (0x01, 0x01)

    var value: PTZSleepTimeout
    
    init(_ value: PTZSleepTimeout) {
        self.value = value
    }
}
