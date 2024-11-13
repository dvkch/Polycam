//
//  LedIntensity.swift
//  PTZ
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public struct PTZLedColorIntensity: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = Self.clamped(ptzValue) }
    public static let minValue: Int = 0
    public static let maxValue: Int = 100
    public static let ptzMin: UInt16 = 0x00
    public static let ptzMax: UInt16 = 0x0F
    public static let unit: String = "%"
    public static let `default`: Self = .mid
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
    
    public static var cliStringExamples: [String] {
        return ["r,g,b"]
    }
    
    public var toJSON: JSONValue {
        return ["r": r.toJSON, "g": g.toJSON, "b": b.toJSON]
    }
}

/// Controls the front led's subdiodes intensity
/// Discovered in the original application's log as Volume, extended through fuzzing
public struct PTZLedIntensityState: PTZReadable, PTZWritable {
    public static let name: String = "LedIntensity"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x25)

    public var value: PTZLedIntensity
    
    public init(_ value: PTZLedIntensity, for variant: PTZNone) {
        self.value = value
    }
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.register.set()) else { return nil }
        self.value = .init(
            r: message.parseArgument(position: .raw8(3)),
            g: message.parseArgument(position: .raw8(5)),
            b: message.parseArgument(position: .raw8(4))
        )
    }

    public func setMessage() -> PTZMessage {
        return .init(Self.register.set(), .init(value.r, .raw8(3)), .init(value.b, .raw8(4)), .init(value.g, .raw8(5)))
    }
}
