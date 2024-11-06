//
//  WhiteLevel.swift
//  SwiftPTZ
//
//  Created by syan on 01/10/2024.
//

import Foundation
import PTZMessaging

public enum PTZWhiteLevel: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case reduced = 0x5A
    case full = 0x64

    public var description: String {
        switch self {
        case .reduced:  return "90%"
        case .full:     return "100%"
        }
    }
    
    public static var `default`: PTZWhiteLevel { .reduced }
}

internal struct PTZWhiteLevelState: PTZParseableState, PTZReadable, PTZWriteable {
    static var name: String = "WhiteLevel"
    static var register: (UInt8, UInt8) = (0x03, 0x3F)

    var value: PTZWhiteLevel
    
    init(_ value: PTZWhiteLevel, for variant: PTZNone) {
        self.value = value
    }
}
