//
//  PTZParseableState.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//


public protocol PTZParseableState: PTZState where Value: PTZValue { }

public extension PTZParseableState where Self: PTZReadable & PTZWritable  {
    init?(message: PTZMessage) {
        guard let variant = message.decodeVariant(Self.register) else { return nil }
        let value: Value = message.parseArgument(position: .single)
        self.init(value, for: variant)
    }
}

public extension PTZParseableState where Self: PTZWritable {
    func setMessage() -> PTZMessage {
        return .init(Self.register.set(variant), value)
    }
}
