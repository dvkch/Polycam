//
//  PTZWritable.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//


public protocol PTZWritable: PTZAddressable where Value: CLIDecodable {
    init(_ value: Value, for variant: Variant)
    func set() -> PTZRequest
    func setMessage() -> PTZMessage
}

public extension PTZWritable {
    func set() -> PTZRequest {
        return .init(name: "Set \(description)", message: setMessage(), waitingTimeIfExecuted: 0, modeConditionRescueRequests: [])
    }
}

public extension PTZWritable where Variant == PTZNone, Value == PTZNone {
    func setMessage() -> PTZMessage {
        return .init(Self.register.set(variant))
    }
}

public extension PTZWritable where Variant == PTZNone {
    init(_ value: Value) {
        self.init(value, for: .init())
    }
}

public extension PTZWritable {
    init?(valueString: String, variantString: String) {
        let variant = Variant.init(from: variantString)
        let value   = Value.init(from: valueString)

        guard let variant, let value else { return nil }
        self.init(value, for: variant)
    }
}
