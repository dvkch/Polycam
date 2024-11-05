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
    
    var modeConditionRescueRequests: [PTZRequest] {
        [PTZAutoFocusState(.off).set()]
    }
}

struct PTZFocusAction: PTZWriteable {
    static var name: String { "Focus" }
    let variant: PTZNone
    var value: PTZNone
    
    init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    func set() -> PTZRequest {
        // takes about 5s to settle down
        return .init(name: "Start \(description)", message: .init((0x45, 0x13)))
    }
}
