//
//  WhiteBalanceCalibration.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

/// Controls the white balance
/// Discovered in the original application
public struct PTZWhiteBalanceCalibrationAction: PTZAddressable, PTZWritable {
    public static var name: String { "WhiteBalanceCalibration" }
    public static var register: PTZRegister<PTZNone> = .init(0x05, 0x17)
    public let variant: PTZNone
    public var value: PTZNone
    
    public init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    public func setMessage() -> PTZMessage {
        return .init(Self.register.set())
    }

    public func set() -> PTZRequest {
        return .init(name: "Start \(description)", message: setMessage(), waitingTimeIfExecuted: 2)
    }
}
