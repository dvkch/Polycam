//
//  FocusAction.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation
import PTZMessaging

/// Starts a request for focus, while in manual focus mode. This is only possible when `PTZAutoFocusState` is `off` and in dev mode.
/// Discovered by fuzzing
public struct PTZFocusAction: PTZState, PTZWriteable {
    public static var name: String { "Start Focus" }
    public let variant: PTZNone
    public var value: PTZNone
    
    public init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    public func setMessage() -> PTZMessage {
        // takes about 5s to settle down
        return .init((0x45, 0x13))
    }
}
