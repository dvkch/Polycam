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
    
    var expectedRunTime: TimeInterval {
        switch self {
        case .settings:          return 5
        case .settingsAndMotors: return 10
        }
    }
    
    var description: String {
        switch self {
        case .settings:           return "settings"
        case .settingsAndMotors:  return "settings and motors"
        }
    }
}

struct PTZResetAction: PTZWriteable {
    static var name: String { "Reset" }
    let variant: PTZNone
    var value: PTZResetKind
    
    init(_ value: PTZResetKind, for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    func set() -> PTZRequest {
        return .init(
            name: "Start \(description)",
            message: .init((0x45, 0x32), value),
            waitingTimeIfExecuted: value.expectedRunTime
        )
    }
}
