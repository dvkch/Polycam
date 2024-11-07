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
public struct PTZWhiteBalanceCalibrationAction: PTZState, PTZWriteable {
    public static var name: String { "WhiteBalanceCalibration" }
    public let variant: PTZNone
    public var value: PTZNone
    
    public init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    public func setMessage() -> PTZMessage {
        return .init((0x45, 0x17))
    }

    public func set() -> PTZRequest {
        return .init(name: "Start \(description)", message: setMessage(), waitingTimeIfExecuted: 2)
    }
}
