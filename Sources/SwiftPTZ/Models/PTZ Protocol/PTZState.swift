//
//  File.swift
//  
//
//  Created by syan on 15/07/2024.
//

import Foundation

protocol PTZState<Variant, Value>: CustomStringConvertible {
    associatedtype Value: Equatable
    associatedtype Variant
    static var name: String { get }
    var variant: Variant { get }
    var value: Value { get set }
}

struct PTZNone: Equatable {}

protocol PTZWriteable<Variant, Value>: PTZState {
    func set() -> PTZRequest
    init(_ value: Value, for variant: Variant)
}

protocol PTZReadable<Variant, Value>: PTZState {
    init?(message: PTZMessage)
    static func get(for variant: Variant) -> PTZRequest
}

extension PTZState where Variant: CustomStringConvertible, Value: CustomStringConvertible {
    var description: String {
        "\(Self.name)(\(variant): \(value))"
    }
}

extension PTZState where Variant == PTZNone, Value: CustomStringConvertible {
    var description: String {
        "\(Self.name)(\(value))"
    }
}

extension PTZState where Variant == PTZNone, Value == PTZNone {
    var description: String {
        "\(Self.name)"
    }
}

protocol PTZInvariantState<Value>: PTZState, PTZReadable, PTZWriteable where Variant == PTZNone {
    static var register: (UInt8, UInt8) { get }
    static var setRegister: (UInt8, UInt8) { get }
    static func get() -> PTZRequest
    init(_ value: Value)
}

extension PTZInvariantState {
    static var setRegister: (UInt8, UInt8) { (register.0 + 0x40, register.1) }

    var variant: Variant { .init() }
    
    init(_ value: Value, for variant: Variant) {
        self.init(value)
    }

    static func get(for variant: Variant) -> PTZRequest {
        return get()
    }

    static func get() -> PTZRequest {
        return .init(name: name, message: .init(register))
    }
}

protocol PTZSingleValueState<Value>: PTZInvariantState where Value: PTZValue {
    var value: Value { get set }
    init(_ value: Value)
    
    var waitingTimeIfExecuted: TimeInterval { get }
    var modeConditionRescueRequests: [PTZRequest] { get }
}

extension PTZSingleValueState {
    init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        let value: Value = message.parseArgument(position: .single)
        self.init(value)
    }

    func set() -> PTZRequest {
        return PTZRequest(
            name: "Set \(Self.name) to \(value)",
            message: .init(Self.setRegister, value),
            waitingTimeIfExecuted: waitingTimeIfExecuted,
            modeConditionRescueRequests: modeConditionRescueRequests
        )
    }
    
    var waitingTimeIfExecuted: TimeInterval { 0 }
    var modeConditionRescueRequests: [PTZRequest] { [] }
}
