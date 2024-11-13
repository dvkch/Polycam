//
//  EffectiveGain.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZEffectiveGain: PTZScaledValue {
    public var ptzValue: UInt16
    public init(ptzValue: UInt16) { self.ptzValue = Self.clamped(ptzValue) }
    public static let minValue: Int = 0
    public static let maxValue: Int = 14
    public static let ptzMin: UInt16 = 0x00
    public static let ptzMax: UInt16 = 0x46
    public static let unit: String = "dB"
}

/// Measures the current ISO level when `PTZGainModeState` is set to `auto`.
/// Discovered by fuzzing
public struct PTZEffectiveGainState: PTZParseableState, PTZReadable {
    public static let name: String = "EffectiveGain"
    public static let register: PTZRegister<PTZNone> = .init(0x03, 0x26)
    
    public var value: PTZEffectiveGain
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.register.set()) else { return nil }
        self.value = message.parseArgument(position: .single)
    }
}
