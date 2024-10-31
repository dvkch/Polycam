//
//  AutoExposure.swift
//  SwiftPTZ
//
//  Created by syan on 31/10/2024.
//

import Foundation

#warning("Add comments to all the states, explaning how they were found and how they work")
struct PTZAutoExposureState: PTZSingleValueState {
    static var name: String = "AutoExposure"
    static var register: (UInt8, UInt8) = (0x02, 0x11)

    var value: PTZBool
    
    init(_ value: PTZBool) {
        self.value = value
    }
    
    var waitingTimeIfExecuted: TimeInterval { 1 }
    var modeConditionRescueRequests: [any PTZRequest] { [PTZBacklightCompensationState(.on).set()] }
}
