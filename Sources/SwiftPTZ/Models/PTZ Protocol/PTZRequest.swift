//
//  PTZRequest.swift
//  
//
//  Created by syan on 30/12/2023.
//

import Foundation

protocol PTZRequest: CustomStringConvertible {
    var message: PTZMessage { get }
    var waitingTimeIfExecuted: TimeInterval { get }
    var modeConditionRescueRequests: [any PTZRequest] { get }
}

protocol PTZGetRequest<Reply>: PTZRequest {
    associatedtype Reply: PTZSpecificReply
}

protocol PTZActionRequest: PTZRequest {
}

extension PTZRequest {
    var waitingTimeIfExecuted: TimeInterval { 0 }
    var modeConditionRescueRequests: [any PTZRequest] { [] }
}
