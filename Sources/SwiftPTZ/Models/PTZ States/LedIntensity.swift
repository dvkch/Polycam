//
//  LedIntensity.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZLedIntensity: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int { 0 }
    static var maxValue: Int { 15 }
    static var ptzOffset: Int { 0 }
    static var ptzScale: Double { 1 }
    static var `default`: PTZLedIntensity { .init(rawValue: 8) }
}

struct PTZLedIntensityState: PTZInvariantState {
    static let name: String = "LedIntensity"
    static var register: (UInt8, UInt8) = (0x01, 0x25)

    struct Value: Equatable {
        var r: PTZLedIntensity
        var g: PTZLedIntensity
        var b: PTZLedIntensity
    }
    var value: Value
    
    init(_ value: Value) {
        self.value = value
    }
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x25]) else { return nil }
        self.value = .init(
            r: message.parseArgument(position: .raw8(3)),
            g: message.parseArgument(position: .raw8(5)),
            b: message.parseArgument(position: .raw8(4))
        )
    }
    
    func set() -> PTZRequest {
        return PTZStateRequest(
            name: "Set \(description)",
            message: .init([0x41, 0x25], .init(value.r, .raw8(3)), .init(value.b, .raw8(4)), .init(value.g, .raw8(5)))
        )
    }
    
    var description: String {
        return "\(Self.name)(R=\(value.r), G=\(value.g), B=\(value.b))"
    }
}
