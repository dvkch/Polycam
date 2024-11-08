//
//  Clock.swift
//  PTZ
//
//  Created by syan on 11/09/2024.
//

import Foundation
import PTZMessaging

public enum PTZClock: UInt8, PTZVariant {
    case clock1 = 0
    case clock2 = 1
    
    public var description: String {
        switch self {
        case .clock1: return "t1"
        case .clock2: return "t2"
        }
    }
}

extension UInt32: CLIDecodable, JSONEncodable {
    public init?(from cliString: String) {
        guard let value = UInt32(cliString) else { return nil }
        self = value
    }
    
    public var toJSON: JSONValue {
        return self
    }
}

/// Controls the two device's clocks. Those are 32bits, precise to the second and auto increasing
/// Discovered by fuzzing
public struct PTZClockState: PTZReadable, PTZWritable {
    public static let name = "Clock"
    public static let register: PTZRegister<PTZClock> = .init(0x01, 0x5D)

    public var variant: PTZClock
    public var value: UInt32
    
    public init(_ value: UInt32, for variant: PTZClock) {
        self.variant = variant
        self.value = value
    }

    public init?(message: PTZMessage) {
        guard let clock = message.decodeVariant(Self.register) else { return nil }

        let timePart0 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08)).rawValue
        let timePart1 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x04)).rawValue
        let timePart2 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02)).rawValue
        let timePart3 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x01)).rawValue

        self.variant = clock
        self.value = .init(b3: UInt8(timePart3), b2: UInt8(timePart2), b1: UInt8(timePart1), b0: UInt8(timePart0))
    }
    
    public func setMessage() -> PTZMessage {
        return PTZMessage(
            Self.register.set(variant),
            .init(PTZUInt(rawValue: UInt16(value.parts.b0)), .custom(hiIndex: 13, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08)),
            .init(PTZUInt(rawValue: UInt16(value.parts.b1)), .custom(hiIndex: 13, loIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x04)),
            .init(PTZUInt(rawValue: UInt16(value.parts.b2)), .custom(hiIndex: 13, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02)),
            .init(PTZUInt(rawValue: UInt16(value.parts.b3)), .custom(hiIndex: 13, loIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x01))
        )
    }
}
