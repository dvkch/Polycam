//
//  WhiteBalanceTint.swift
//  SwiftPTZ
//
//  Created by syan on 22/09/2024.
//

struct PTZWhiteBalanceTint: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 96
    static var maxValue: Int = 159
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZWhiteBalanceTint { .init(rawValue: 128) }
}

struct PTZWhiteBalanceTintState: PTZSingleValueState {
    static var name: String = "WhiteBalanceTint"
    static var register: (UInt8, UInt8) = (0x03, 0x40)

    var value: PTZWhiteBalanceTint
    
    init(_ value: PTZWhiteBalanceTint) {
        self.value = value
    }
    
    var modeConditionRescueRequests: [PTZRequest] {
        [PTZWhiteBalanceState(.manual).set()]
    }
}

