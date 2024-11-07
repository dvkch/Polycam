//
//  DrunkTest.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation
import PTZMessaging

public struct PTZDrunkTestAction: PTZState, PTZWriteable {
    public static var name: String { "DrunkTest" }
    public let variant: PTZNone
    public var value: PTZNone
    
    public init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    public func setMessage() -> PTZMessage {
        return .init((0x45, 0x14), PTZDrunkTestPhase.running)
    }
}

