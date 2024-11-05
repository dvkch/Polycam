//
//  PTZRequest.swift
//  
//
//  Created by syan on 30/12/2023.
//

import Foundation

public struct PTZRequest {
    let name: String
    let message: PTZMessage
    let waitingTimeIfExecuted: TimeInterval
    let modeConditionRescueRequests: [PTZRequest]
    
    public init(name: String, message: PTZMessage, waitingTimeIfExecuted: TimeInterval = 0, modeConditionRescueRequests: [PTZRequest] = []) {
        self.name = name
        self.message = message
        self.waitingTimeIfExecuted = waitingTimeIfExecuted
        self.modeConditionRescueRequests = modeConditionRescueRequests
    }
}

extension PTZRequest {
    public static func unknown(_ command: (Byte, Byte), arg: UInt16?) -> PTZRequest {
        let message: PTZMessage
        if let arg {
            message = .init(command, .init(PTZUInt(rawValue: arg), .single))
        }
        else {
            message = .init(command)
        }
        
        return .init(name: "Unknown(\(message.bytes.hexString))", message: message)
    }

    public static func raw(_ bytes: Bytes) -> PTZRequest {
        return .init(name: "Raw(\(bytes.hexString))", message: .init(bytes: bytes))
    }
}

extension PTZRequest: CustomStringConvertible {
    public var description: String {
        name
    }
}
