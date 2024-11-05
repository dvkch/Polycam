//
//  LedIntensity.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

struct PTZLedColorIntensity: PTZScaledValue {
    var rawValue: Int
    static var minValue: Int { 0 }
    static var maxValue: Int { 15 }
    static var ptzOffset: Int { 0 }
    static var ptzScale: Double { 1 }
    static var `default`: PTZLedColorIntensity { .init(rawValue: 8) }
}

struct PTZLedIntensity: Equatable, CustomStringConvertible {
    var r: PTZLedColorIntensity
    var g: PTZLedColorIntensity
    var b: PTZLedColorIntensity
    var description: String { "R=\(r), G=\(g), B=\(b)" }
}

struct PTZLedIntensityState: PTZInvariantState {
    static let name: String = "LedIntensity"
    static var register: (UInt8, UInt8) = (0x01, 0x25)

    var value: PTZLedIntensity
    
    init(_ value: PTZLedIntensity) {
        self.value = value
    }
    
    init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        self.value = .init(
            r: message.parseArgument(position: .raw8(3)),
            g: message.parseArgument(position: .raw8(5)),
            b: message.parseArgument(position: .raw8(4))
        )
    }
    
    func set() -> PTZRequest {
        return .init(
            name: "Set \(description)",
            message: .init(Self.setRegister, .init(value.r, .raw8(3)), .init(value.b, .raw8(4)), .init(value.g, .raw8(5)))
        )
    }
}
