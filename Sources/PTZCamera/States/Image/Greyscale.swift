//
//  Greyscale.swift
//  PTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

public struct PTZGreyscaleState: PTZInvariantState, PTZReadable, PTZWriteable {
    public static var name: String = "Greyscale"
    public static var register: (UInt8, UInt8) = (0x01, 0x3A)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
    
    public init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        let value: Value = message.parseArgument(position: .single)
        self.init(.init(rawValue: !value.rawValue))
    }

    public func setMessage() -> PTZMessage {
        return .init(Self.setRegister, PTZBool(rawValue: !value.rawValue))
    }
}
