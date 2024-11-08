//
//  GainEffective.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZGainEffective: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = ptzValue }
    public static let minValue: Int = 0
    public static let maxValue: Int = 14
    public static let ptzMin: UInt16 = 0x00
    public static let ptzMax: UInt16 = 0x46
    public static let unit: String = "dB"
}

/// Measures the current ISO level when `PTZGainModeState` is set to `auto`.
/// Discovered by fuzzing
public struct PTZGainEffectiveState: PTZParseableState, PTZReadable {
    public static var name: String = "GainEffective"
    public static var register: (UInt8, UInt8) = (0x03, 0x26)
    
    public var value: PTZGainEffective
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        self.value = message.parseArgument(position: .single)
    }
}
