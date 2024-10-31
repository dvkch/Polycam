//
//  WhiteBalanceTemp.swift
//  SwiftPTZ
//
//  Created by syan on 22/09/2024.
//

struct PTZWhiteBalanceTemp: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 96
    static var maxValue: Int = 159
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZWhiteBalanceTemp { .init(rawValue: 128) }
}

struct PTZWhiteBalanceTempState: PTZSingleValueState {
    static var name: String = "WhiteBalanceTemp"
    static var register: (UInt8, UInt8) = (0x03, 0x41)

    var value: PTZWhiteBalanceTemp
    
    init(_ value: PTZWhiteBalanceTemp) {
        self.value = value
    }
    
    func set() -> any PTZRequest {
        return PTZStateRequest(
            name: "Set \(description)",
            message: .init([Self.register.0 + 0x40, Self.register.1], value),
            modeConditionRescueRequests: [PTZWhiteBalanceState(.manual).set()]
        )
#warning("set up all mode conditions rescues for all requests")
    }
}

