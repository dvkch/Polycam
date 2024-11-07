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

public struct PTZLedIntensity: Equatable, CustomStringConvertible, CLIDecodable, JSONEncodable {
    public var r: PTZLedColorIntensity
    public var g: PTZLedColorIntensity
    public var b: PTZLedColorIntensity
    public var description: String { "R=\(r), G=\(g), B=\(b)" }
    
    public init(r: PTZLedColorIntensity, g: PTZLedColorIntensity, b: PTZLedColorIntensity) {
        self.r = r
        self.g = g
        self.b = b
    }

    public init?(from cliString: String) {
        let parts = cliString.split(separator: ",")
        guard parts.count == 3 else { return nil }
        
        guard let r = PTZLedColorIntensity(from: String(parts[0])) else { return nil }
        guard let g = PTZLedColorIntensity(from: String(parts[1])) else { return nil }
        guard let b = PTZLedColorIntensity(from: String(parts[2])) else { return nil }
        self.r = r
        self.g = g
        self.b = b
    }
    
    public var toJSON: JSONValue {
        return ["r": r.toJSON, "g": g.toJSON, "b": b.toJSON]
    }
}

public struct PTZLedIntensityState: PTZInvariantState, PTZReadable, PTZWriteable {
    public static let name: String = "LedIntensity"
    public static var register: (UInt8, UInt8) = (0x01, 0x25)

    public var value: PTZLedIntensity
    
    public init(_ value: PTZLedIntensity, for variant: PTZNone) {
        self.value = value
    }
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        self.value = .init(
            r: message.parseArgument(position: .raw8(3)),
            g: message.parseArgument(position: .raw8(5)),
            b: message.parseArgument(position: .raw8(4))
        )
    }

    public func setMessage() -> PTZMessage {
        return .init(Self.setRegister, .init(value.r, .raw8(3)), .init(value.b, .raw8(4)), .init(value.g, .raw8(5)))
    }
}
