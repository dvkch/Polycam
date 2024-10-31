//
//  File.swift
//  
//
//  Created by syan on 15/07/2024.
//

import Foundation

#warning("TODO: try to generalize into PTZAction and PTZState protocols, with helpers to handle 1, 2 or 3 elements")

protocol PTZState<Value>: CustomStringConvertible {
    associatedtype Value
    
    static var getCommand: (Byte, Byte) { get }
    static var setCommand: (Byte, Byte) { get }
    
    func getRequest() -> PTZRequest
    func setRequest(value: Value) -> PTZRequest
    func parseResponse(_ reply: Bytes) -> Value?
}

struct PTZStateRequest: PTZRequest {
    var bytes: Bytes
    var description: String
    var waitingTimeIfExecuted: TimeInterval
}