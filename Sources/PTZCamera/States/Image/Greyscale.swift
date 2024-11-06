//
//  Greyscale.swift
//  SwiftPTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

internal struct PTZGreyscaleState: PTZInvariantState, PTZReadable, PTZWriteable {
    static var name: String = "Greyscale"
    static var register: (UInt8, UInt8) = (0x01, 0x3A)

    var value: PTZBool
    
    init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
    
    init?(message: PTZMessage) {
        guard message.isValidReply(Self.setRegister) else { return nil }
        let value: Value = message.parseArgument(position: .single)
        self.init(.init(rawValue: !value.rawValue))
    }

    func setMessage() -> PTZMessage {
        return .init(Self.setRegister, PTZBool(rawValue: !value.rawValue))
    }
}
