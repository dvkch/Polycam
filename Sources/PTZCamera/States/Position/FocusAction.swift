//
//  FocusAction.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation
import PTZMessaging

/// Starts a request for focus, while in manual focus mode. This is only possible when `PTZAutoFocusState` is `off` and in dev mode.
/// Takes about 5 seconds to settle down
/// Discovered by fuzzing
public struct PTZFocusAction: PTZWritable {
    public static let name: String = "Start Focus"
    public static let register: PTZRegister<PTZNone> = .init(0x05, 0x13)

    public var value: PTZNone
    
    public init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.value = value
    }
}
