//
//  File.swift
//  
//
//  Created by syan on 15/07/2024.
//

import Foundation

#warning("TODO: try to generalize into PTZAction and PTZState protocols, with helpers to handle 1, 2 or 3 elements")

protocol PTZState<Variant, Value>: CustomStringConvertible {
    associatedtype Value: Equatable
    associatedtype Variant
    var variant: Variant { get }
    var value: Value { get set }
    init(_ value: Value, for variant: Variant)
    init?(message: PTZMessage)
    func set() -> any PTZRequest
    static var name: String { get }
    static func get(for variant: Variant) -> any PTZRequest
}

extension PTZState where Variant: CustomStringConvertible, Value: CustomStringConvertible {
    var description: String {
        "\(Self.name)(\(variant): \(value))"
    }
}

protocol PTZInvariantState<Value>: PTZState where Variant == Void {
    static var register: (UInt8, UInt8) { get }
    static func get() -> PTZRequest
    init(_ value: Value)
}

extension PTZInvariantState {
    var variant: Variant { () }
    
    init(_ value: Value, for variant: Variant) {
        self.init(value)
    }

    static func get(for variant: Variant) -> any PTZRequest {
        return get()
    }

    static func get() -> any PTZRequest {
        return PTZStateRequest(name: name, message: .init([register.0, register.1]))
    }
}

extension PTZInvariantState where Value: CustomStringConvertible {
    var description: String {
        "\(Self.name)(\(value))"
    }
}

protocol PTZSingleValueState<Value>: PTZInvariantState where Value: PTZValue {
    var value: Value { get set }
    init(_ value: Value)
    
    var waitingTimeIfExecuted: TimeInterval { get }
    var modeConditionRescueRequests: [any PTZRequest] { get }
}

extension PTZSingleValueState {
    init?(message: PTZMessage) {
        guard message.isValidReply([Self.register.0 + 0x40, Self.register.1]) else { return nil }
        let value: Value = message.parseArgument(position: .single)
        self.init(value)
    }

    func set() -> PTZRequest {
        return PTZStateRequest(
            name: "Set \(Self.name) to \(value)",
            message: .init([Self.register.0 + 0x40, Self.register.1], value),
            waitingTimeIfExecuted: waitingTimeIfExecuted,
            modeConditionRescueRequests: modeConditionRescueRequests
        )
    }
    
    var waitingTimeIfExecuted: TimeInterval { 0 }
    var modeConditionRescueRequests: [any PTZRequest] { [] }
}

#warning("Rename into PTZRequest")
struct PTZStateRequest: PTZRequest {
    let name: String
    let message: PTZMessage
    let waitingTimeIfExecuted: TimeInterval
    let modeConditionRescueRequests: [any PTZRequest]
    
    init(name: String, message: PTZMessage, waitingTimeIfExecuted: TimeInterval = 0, modeConditionRescueRequests: [any PTZRequest] = []) {
        self.name = name
        self.message = message
        self.waitingTimeIfExecuted = waitingTimeIfExecuted
        self.modeConditionRescueRequests = modeConditionRescueRequests
    }

    var description: String {
        name
    }
}
