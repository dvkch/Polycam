//
//  NoiseReduction.swift
//  PTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

/// Controls the camera's integrated noise reduction. Without it the image becomes very noisy and jittery in low light
/// Discovered by fuzzing
public struct PTZNoiseReductionState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "NoiseReduction"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x3C)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
