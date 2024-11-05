//
//  DeviceError.swift
//  SwiftPTZ
//
//  Created by syan on 05/11/2024.
//

import SwiftSerial

public enum DeviceError: Error {
    case serialError(PortError)
    case timeout
    case fail
    case reset
    case notExecuted(error: PTZReply.CommandError)
    case missingReply
    case wrongReply(PTZReply)
}
