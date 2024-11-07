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
    case notExecuted(error: PTZReply.CommandError)
    case missingReply
    case wrongReply(PTZReply)
}

extension DeviceError: LocalizedError {
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
        case .notExecuted(let e):
            return "Not executed: \(e.description)"
        case .missingReply:
            return "Missing reply"
        case .wrongReply(let r):
            return "Wrong reply, received: \(r)"
        }
    }
}
