//
//  Reset.swift
//  
//
//  Created by syan on 11/09/2024.
//

import Foundation

#warning("allowed from 00 to 07, but mode condition except on 0?")
enum PTZResetKind: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case sensor = 0x00
    case sensorAndMotors = 0x01
    static var `default`: PTZResetKind { .sensor }
    
    var description: String {
        switch self {
        case .sensor:           return "sensor"
        case .sensorAndMotors:  return "sensor and motors"
        }
    }
}

struct PTZRequestReset: PTZRequest {
    let reset: PTZResetKind
    var bytes: Bytes { buildBytes([0x45, 0x32], reset) }
    var description: String { "Resetting \(reset)" }
    var waitingTimeIfExecuted: TimeInterval {
        switch reset {
        case .sensor:           return 5
        case .sensorAndMotors:  return 10
        }
    }
}
