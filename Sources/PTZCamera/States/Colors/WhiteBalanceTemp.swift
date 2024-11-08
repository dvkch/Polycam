//
//  WhiteBalanceTemp.swift
//  PTZ
//
//  Created by syan on 22/09/2024.
//

import Foundation
import PTZMessaging

public struct PTZWhiteBalanceTemp: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x60
    public static let ptzMax: UInt16 = 0x9F
    public static let unit: String = "%"
    public static let `default`: Self = .mid
}

/// Controls the white balance temperature, from blue to yellow
/// Discovered by fuzzing
public struct PTZWhiteBalanceTempState: PTZParseableState, PTZReadable, PTZWritable {
    public static var name: String = "WhiteBalanceTemp"
    public static var register: PTZRegister<PTZNone> = .init(0x03, 0x41)

    public var value: PTZWhiteBalanceTemp
    
    public init(_ value: PTZWhiteBalanceTemp, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), modeConditionRescueRequests: [PTZWhiteBalanceState(.manual).set()])
    }
}

