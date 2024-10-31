//
//  Reset.swift
//  
//
//  Created by syan on 11/09/2024.
//

import Foundation

enum PTZResetKind: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case settings          = 0x00
    case settingsAndMotors = 0x01
    static var `default`: PTZResetKind { .settings }
    
    var description: String {
        switch self {
        case .settings:           return "settings"
        case .settingsAndMotors:  return "settings and motors"
        }
    }
}

struct PTZRequestReset: PTZRequest {
    let reset: PTZResetKind
    var message: PTZMessage { .init([0x45, 0x32], reset) }
    var description: String { "Resetting \(reset)" }
    var waitingTimeIfExecuted: TimeInterval {
        switch reset {
        case .settings:          return 5
        case .settingsAndMotors: return 10
        }
    }
}
