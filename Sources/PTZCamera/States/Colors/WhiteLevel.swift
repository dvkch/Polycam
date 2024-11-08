//
//  WhiteLevel.swift
//  PTZ
//
//  Created by syan on 01/10/2024.
//

import Foundation
import PTZMessaging

public enum PTZWhiteLevel: UInt16, PTZEnumValue {
    case reduced = 0x5A
    case full = 0x64

    public var description: String {
        switch self {
        case .reduced:  return "90%"
        case .full:     return "100%"
        }
    }
    
    public static var `default`: Self = .reduced
}

/// Controls the image's white clipping. 90% is less straining on the eyes
/// Discovered by fuzzing
public struct PTZWhiteLevelState: PTZParseableState, PTZReadable, PTZWritable {
    public static var name: String = "WhiteLevel"
    public static var register: PTZRegister<PTZNone> = .init(0x03, 0x3F)

    public var value: PTZWhiteLevel
    
    public init(_ value: PTZWhiteLevel, for variant: PTZNone) {
        self.value = value
    }
}
