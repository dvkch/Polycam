//
//  DrunkTest.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

/// Starts a self test mode (it seems)
/// Discovered by fuzzing
///
/// Nota:
/// - only available in dev mode, otherwise those requests will return "FAIL"
/// - the test looks like it could be hard on the hardware, I have no clue about its
///   original purpose, but phase 1 seems demending
/// - phase 1 runs for about 130 seconds, during which most other commands
///   will either fail or do nothing. there seems to be no way of stopping it, except
///   for unplugging and replugging the device.
/// - phase 2 can be stopped by sending a SetPosition or Move request. Obtaining the phase will
///   still return 2, but the autonomous camera movements will quickly stop
public struct PTZDrunkTestAction: PTZWritable {
    public static var name: String { "DrunkTest" }
    public static var register: PTZRegister<PTZNone> = .init(0x05, 0x14)
    public let variant: PTZNone
    public var value: PTZNone
    
    public init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    public func setMessage() -> PTZMessage {
        return .init(Self.register.set(), PTZDrunkTestPhase.running)
    }
}

