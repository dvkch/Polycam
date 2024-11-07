//
//  DrunkTestPhase.swift
//  PTZ
//
//  Created by syan on 20/10/2024.
//

import Foundation
import PTZMessaging

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

/// Determine the status of the self test, see `PTZDrunkTestAction`
/// Discovered by fuzzing
public struct PTZDrunkTestPhaseState: PTZParseableState, PTZReadable {
    public static var name: String { "DrunkTestPhase" }
    public static var register: (UInt8, UInt8) = (0x01, 0x42)
    public let variant: PTZNone = .init()
    public var value: PTZDrunkTestPhase
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        self.value = message.parseArgument(position: .single)
    }
}
