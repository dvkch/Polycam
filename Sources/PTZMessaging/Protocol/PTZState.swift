//
//  File.swift
//  
//
//  Created by syan on 15/07/2024.
//

import Foundation

public protocol CLIDecodable {
    init?(from cliString: String)
}

public protocol JSONEncodable {
    var toJSON: JSONValue { get }
}

// MARK: State
public protocol PTZState<Variant, Value>: CustomStringConvertible {
    associatedtype Value: Equatable & CustomStringConvertible
    associatedtype Variant: CLIDecodable & CustomStringConvertible
    static var name: String { get }
    var variant: Variant { get }
    var value: Value { get set }
}

public extension PTZState {
    var description: String {
        if variant is PTZNone && value is PTZNone {
            Self.name
        }
        else if variant is PTZNone {
            "\(Self.name)(\(value))"
        }
        else {
            "\(Self.name)(\(variant): \(value))"
        }
    }
}

// MARK: InvariantState
public protocol PTZInvariantState<Value>: PTZState where Variant == PTZNone {
    static var register: (UInt8, UInt8) { get }
    static var setRegister: (UInt8, UInt8) { get }
}

public extension PTZInvariantState {
    static var setRegister: (UInt8, UInt8) { (register.0 + 0x40, register.1) }
    var variant: Variant { .init() }
}

// MARK: Readable
public protocol PTZReadable<Variant, Value>: PTZState where Value: JSONEncodable {
    init?(message: PTZMessage)
    static func get(for variant: Variant) -> PTZRequest
}

public extension PTZReadable where Self: PTZInvariantState {
    static func get() -> PTZRequest {
        return get(for: .init())
    }

    static func get(for variant: Variant) -> PTZRequest {
        return .init(name: name, message: .init(register))
    }
}

// MARK: Writeable
public protocol PTZWriteable<Variant, Value>: PTZState where Value: CLIDecodable {
    init(_ value: Value, for variant: Variant)
    func set() -> PTZRequest
    func setMessage() -> PTZMessage
}

public extension PTZWriteable {
    init?(valueString: String, variantString: String) {
        let variant = Variant.init(from: variantString)
        let value   = Value.init(from: valueString)

        guard let variant, let value else { return nil }
        self.init(value, for: variant)
    }
}

public extension PTZWriteable {
    func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), waitingTimeIfExecuted: 0, modeConditionRescueRequests: [])
    }
}

public extension PTZWriteable where Self: PTZInvariantState {
    init(_ value: Value) {
        self.init(value, for: .init())
    }
}

// MARK: SingleValue
public protocol PTZParseableState: PTZInvariantState where Value: PTZValue { }

public extension PTZParseableState where Self: PTZReadable & PTZWriteable {
    init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        let value: Value = message.parseArgument(position: .single)
        self.init(value)
    }
}

public extension PTZParseableState where Self: PTZWriteable {
    func setMessage() -> PTZMessage {
        return .init(Self.setRegister, value)
    }
}

// MARK: Combo
public protocol PTZReadableCombo<Value>: PTZState where Variant == PTZNone, Value: JSONEncodable {
    init?(messages: [PTZMessage])
    static func get() -> [PTZRequest]
}

public protocol PTZWriteableCombo<Value>: PTZState where Variant == PTZNone, Value: CLIDecodable {
    init(_ value: Value)
    func set() -> [PTZRequest]
}

public extension PTZWriteableCombo {
    init?(valueString: String) {
        guard let value = Value.init(from: valueString) else { return nil }
        self.init(value)
    }
}
