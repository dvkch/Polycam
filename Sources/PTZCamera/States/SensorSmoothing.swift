//
//  SensorSmoothing.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

internal struct PTZSensorSmoothingState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "SensorSmoothing"
    static var register: (UInt8, UInt8) = (0x01, 0x3B)

    var value: PTZBool
    
    init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
