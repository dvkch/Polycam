//
//  Focus.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation

struct PTZFocus: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int = 240
    static var maxValue: Int = 768 // max bytes are 06 00
    static var ptzOffset: Int = 0
    static var ptzScale: Double = 1
    static var `default`: PTZFocus { .init(rawValue: 0) }
}

struct PTZFocusState: PTZSingleValueState {
    static var name: String = "Focus"
    static var register: (UInt8, UInt8) = (0x03, 0x03)

    var value: PTZFocus
    
    init(_ value: PTZFocus) {
        self.value = value
    }
    
    func set() -> any PTZRequest {
        return PTZStateRequest(
            name: "Set \(description)",
            message: .init([Self.register.0 + 0x40, Self.register.1], value),
            modeConditionRescueRequests: [PTZAutoFocusState(.off).set()]
        )
    }
}

struct PTZRequestStartFocus: PTZRequest {
    var message: PTZMessage { .init([0x45, 0x13]) }
    var description: String { "Start focus" } // takes about 5s to settle down
}
