//
//  DeviceError.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

import SwiftSerial
import Foundation

public enum DeviceError: Error {
    case noSerialDevice
    case serialError(PortError)
    case timeout
    case fail
    case reset
    case notExecuted(error: PTZReply.CommandError, request: PTZRequest)
    case missingReply
    case wrongReply(PTZReply)
}

extension DeviceError: LocalizedError, RecoverableError {
    public func attemptRecovery(optionIndex recoveryOptionIndex: Int) -> Bool {
        // Could actually be implemented later on with some rework (camera would have to be available somewhere)
        return false
    }
    
    public var recoveryOptions: [String] {
        if case .notExecuted(.modeCondition, let r) = self, r.modeConditionRescueRequests.isNotEmpty {
            let sets = r.modeConditionRescueRequests.map(\.description).joined(separator: ", ")
            return ["Suggestion: \(sets)"]
        }
        return []
    }
    
    public var errorDescription: String? {
        switch self {
        case .noSerialDevice:
            return "No serial device available"
        case .serialError(let e):
            return "Serial error: \(e.localizedDescription)"
        case .timeout:
            return "Serial timeout"
        case .fail:
            return "Fail"
        case .reset:
            return "Reset"
        case .notExecuted(let e, _):
            return "Not executed: \(e.description)"
        case .missingReply:
            return "Missing reply"
        case .wrongReply(let r):
            return "Wrong reply, received: \(r)"
        }
    }
}
