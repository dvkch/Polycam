//
//  WhiteLevel.swift
//  SwiftPTZ
//
//  Created by syan on 01/10/2024.
//

import Foundation

enum PTZWhiteLevel: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case reduced = 0x5A
    case full = 0x64

    var description: String {
        switch self {
        case .reduced:  return "90%"
        case .full:     return "100%"
        }
    }
    
    static var `default`: PTZWhiteLevel { .reduced }
}

struct PTZWhiteLevelState: PTZSingleValueState {
    static var name: String = "WhiteLevel"
    static var register: (UInt8, UInt8) = (0x03, 0x3F)

    var value: PTZWhiteLevel
    
    init(_ value: PTZWhiteLevel) {
        self.value = value
    }
}
