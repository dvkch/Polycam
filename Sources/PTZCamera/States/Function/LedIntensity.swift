//
//  LedIntensity.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZLedColorIntensity: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int { 0 }
    public static var maxValue: Int { 15 }
    public static var ptzOffset: Int { 0 }
    public static var ptzScale: Double { 1 }
    public static var `default`: PTZLedColorIntensity { .init(rawValue: 8) }
}

public struct PTZLedIntensity: Equatable, CustomStringConvertible, Codable {
    var r: PTZLedColorIntensity
    var g: PTZLedColorIntensity
    var b: PTZLedColorIntensity
    public var description: String { "R=\(r), G=\(g), B=\(b)" }
}

internal struct PTZLedIntensityState: PTZInvariantState, PTZReadable, PTZWriteable {
    static let name: String = "LedIntensity"
    static var register: (UInt8, UInt8) = (0x01, 0x25)

    var value: PTZLedIntensity
    
    init(_ value: PTZLedIntensity, for variant: PTZNone) {
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

    func setMessage() -> PTZMessage {
        return .init(Self.setRegister, .init(value.r, .raw8(3)), .init(value.b, .raw8(4)), .init(value.g, .raw8(5)))
    }
}
