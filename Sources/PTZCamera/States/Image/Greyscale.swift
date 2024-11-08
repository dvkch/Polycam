//
//  Greyscale.swift
//  PTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

/// Switch to a greyscale image
/// Discovered by fuzzing
///
/// Only available in dev mode
public struct PTZGreyscaleState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "Greyscale"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x3A)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.register.set()) else { return nil }
        let value: Value = message.parseArgument(position: .single)
        self.init(.init(rawValue: !value.rawValue))
    }

    public func setMessage() -> PTZMessage {
        return .init(Self.register.set(), PTZBool(rawValue: !value.rawValue))
    }
}
