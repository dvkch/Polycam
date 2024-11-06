//
//  WhiteBalanceTemp.swift
//  SwiftPTZ
//
//  Created by syan on 22/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZWhiteBalanceTemp: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 96
    public static var maxValue: Int = 159
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 1
    public static var `default`: PTZWhiteBalanceTemp { .init(rawValue: 128) }
}

public struct PTZWhiteBalanceTempState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "WhiteBalanceTemp"
    public static var register: (UInt8, UInt8) = (0x03, 0x41)

    public var value: PTZWhiteBalanceTemp
    
    public init(_ value: PTZWhiteBalanceTemp, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), modeConditionRescueRequests: [PTZWhiteBalanceState(.manual).set()])
    }
    
#warning("set up all mode conditions rescues for all requests")
}

