//
//  DrunkTestPhase.swift
//  PTZ
//
//  Created by syan on 20/10/2024.
//

import Foundation
import PTZMessaging

// Nota:
// - only available in experimental mode, otherwise those requests will return "FAIL"
// - the test looks like it could be hard on the hardware, I have no clue about its
//   original purpose, but phase 1 seems demending
// - phase 1 runs for about 130 seconds, during which most other commands
//   will either fail or do nothing. there seems to be no way of stopping it, except
//   for unplugging and replugging the device.
// - phase 2 can be stopped by sending a SetPosition or Move request. Obtaining the phase will
//   still return 2, but the autonomous camera movements will quickly stop
public enum PTZDrunkTestPhase: UInt16, CaseIterable, PTZValue {
    case neverLaunched = 0
    case running = 1
    case finishingOrFinished = 2
    
    public var description: String {
        switch self {
        case .neverLaunched:        return "Never launched"
        case .running:              return "Running"
        case .finishingOrFinished:  return "Finishing or finished"
        }
    }
}

public struct PTZDrunkTestPhaseState: PTZParseableState, PTZReadable {
    public static var name: String { "DrunkTestPhase" }
    public static var register: (UInt8, UInt8) = (0x01, 0x42)
    public let variant: PTZNone = .init()
    public var value: PTZDrunkTestPhase
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.register) else { return nil }
        self.value = message.parseArgument(position: .single)
    }
}
