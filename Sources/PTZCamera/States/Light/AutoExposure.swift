//
//  AutoExposure.swift
//  SwiftPTZ
//
//  Created by syan on 31/10/2024.
//

import Foundation
import PTZMessaging

#warning("Add comments to all the states, explaning how they were found and how they work")
#warning("Put each state in its own file")
public struct PTZAutoExposureState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "AutoExposure"
    public static var register: (UInt8, UInt8) = (0x02, 0x11)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
    
    func setRequest() -> PTZRequest {
        return .init(
            name: "Set \(description)",
            message: setMessage(),
            waitingTimeIfExecuted: 1,
            modeConditionRescueRequests: [PTZBacklightCompensationState(.on).set()]
        )
    }
}
