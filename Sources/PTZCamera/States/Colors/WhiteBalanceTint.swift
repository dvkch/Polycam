//
//  WhiteBalanceTint.swift
//  PTZ
//
//  Created by syan on 22/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZWhiteBalanceTint: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 96
    public static var maxValue: Int = 159
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1
    public static var `default`: PTZWhiteBalanceTint { .init(rawValue: 128) }
}

public struct PTZWhiteBalanceTintState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "WhiteBalanceTint"
    public static var register: (UInt8, UInt8) = (0x03, 0x40)

    public var value: PTZWhiteBalanceTint
    
    public init(_ value: PTZWhiteBalanceTint, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), modeConditionRescueRequests: [PTZWhiteBalanceState(.manual).set()])
    }
}

