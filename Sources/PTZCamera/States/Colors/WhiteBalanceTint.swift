//
//  WhiteBalanceTint.swift
//  SwiftPTZ
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

internal struct PTZWhiteBalanceTintState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "WhiteBalanceTint"
    static var register: (UInt8, UInt8) = (0x03, 0x40)

    var value: PTZWhiteBalanceTint
    
    init(_ value: PTZWhiteBalanceTint, for variant: PTZNone) {
        self.value = value
    }
    
    func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), modeConditionRescueRequests: [PTZWhiteBalanceState(.manual).set()])
    }
}

