//
//  Power.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public enum PTZPower: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case on         = 0x00
    case sleeping   = 0x02
    case standby    = 0x10
    case off        = 0x12 // it is not possible to restart the camera programmatically from that point!

    public var description: String {
        switch self {
        case .on:       return "on"
        case .sleeping: return "sleeping"
        case .standby:  return "standby"
        case .off:      return "off"
        }
    }
}

internal struct PTZPowerState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "Power"
    static var register: (UInt8, UInt8) = (0x01, 0x00)
    
    var value: PTZPower
    
    init(_ value: PTZPower, for variant: PTZNone) {
        self.value = value
    }
    
    func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), waitingTimeIfExecuted: (value == .on ? 5 : 1))
    }
}
