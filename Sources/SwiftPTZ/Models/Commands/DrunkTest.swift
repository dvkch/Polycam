//
//  DrunkTest.swift
//  SwiftPTZ
//
//  Created by syan on 20/10/2024.
//

import Foundation

// Nota:
// - only available in experimental mode, otherwise those requests will return "FAIL"
// - the test looks like it could be hard on the hardware, I have no clue about its
//   original purpose, but phase 1 seems demending
// - phase 1 runs for about 130 seconds, during which most other commands
//   will either fail or do nothing. there seems to be no way of stopping it, except
//   for unplugging and replugging the device.
// - phase 2 can be stopped by sending a SetPosition or Move request. Obtaining the phase will
//   still return 2, but the autonomous camera movements will quickly stop
enum PTZDrunkTestPhase: UInt16, CaseIterable, PTZValue {
    case neverLaunched = 0
    case running = 1
    case finishingOrFinished = 2
    
    var description: String {
        switch self {
        case .neverLaunched:        return "Never launched"
        case .running:              return "Running"
        case .finishingOrFinished:  return "Finishing or finished"
        }
    }
    
    static var `default`: PTZDrunkTestPhase { .running }
}

struct PTZStartDrunkTest: PTZRequest {
    var bytes: Bytes { buildBytes([0x45, 0x14, 0x01]) }
    var description: String { "Start drunk test" }
}

struct PTZRequestGetDrunkTestPhase: PTZGetRequest {
    typealias Reply = PTZReplyDevMode
    var bytes: Bytes { buildBytes([0x01, 0x42]) }
    var description: String { "Get drunk test phase" }
}

struct PTZReplyDrunkTestPhase: PTZReply {
    let phase: PTZDrunkTestPhase
    
    init?(message: PTZMessage) {
        guard message.isValidReply([0x41, 0x42]) else { return nil }
        self.phase = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "DrunkTestPhase(\(phase))"
    }
}
