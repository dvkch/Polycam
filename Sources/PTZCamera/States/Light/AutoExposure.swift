//
//  AutoExposure.swift
//  PTZ
//
//  Created by syan on 31/10/2024.
//

import Foundation
import PTZMessaging

/// Controls the auto exposure
/// Discovered in the original application's logs
public struct PTZAutoExposureState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "AutoExposure"
    public static let register: PTZRegister<PTZNone> = .init(0x02, 0x11)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        return .init(
            name: "Set \(description)",
            message: setMessage(),
            waitingTimeIfExecuted: 0.2,
            modeConditionRescueRequests: [PTZBacklightCompensationState(.on).set()]
        )
    }
}
