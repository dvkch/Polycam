//
//  Mire.swift
//  PTZ
//
//  Created by syan on 06/08/2024.
//

import Foundation
import PTZMessaging

/// Disables proper video output and just shows a mire
/// Discovered by fuzzing
public struct PTZMireState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "Mire"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x10)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
