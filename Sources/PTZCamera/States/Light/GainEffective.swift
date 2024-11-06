//
//  GainEffective.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZGainEffective: PTZScaledValue {
    public var rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    public static var minValue: Int = 0
    public static var maxValue: Int = 70
    public static var ptzOffset: Int = 0
    public static var ptzScale: Double = 5
    public var description: String { "\(rawValue)dB" }
}

public struct PTZGainEffectiveState: PTZParseableState, PTZReadable {
    public static var name: String = "GainEffective"
    public static var register: (UInt8, UInt8) = (0x03, 0x26)
    
    public var value: PTZGainEffective
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        self.value = message.parseArgument(position: .single)
    }
}
