//
//  Focus.swift
//
//
//  Created by syan on 13/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZFocus: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 240
    public static var maxValue: Int = 768 // max bytes are 06 00
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1
}

internal struct PTZFocusState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "Focus"
    static var register: (UInt8, UInt8) = (0x03, 0x03)

    var value: PTZFocus
    
    init(_ value: PTZFocus, for variant: PTZNone) {
        self.value = value
    }
    
    func set() -> PTZRequest {
        return .init(
            name: "Set \(description)", message: setMessage(),
            modeConditionRescueRequests: [PTZAutoFocusState(.off).set()]
        )
    }
}

internal struct PTZFocusAction: PTZState, PTZWriteable {
    static var name: String { "Start Focus" }
    let variant: PTZNone
    var value: PTZNone
    
    init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    func setMessage() -> PTZMessage {
        // takes about 5s to settle down
        return .init((0x45, 0x13))
    }
}
