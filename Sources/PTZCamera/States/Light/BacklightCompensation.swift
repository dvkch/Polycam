//
//  BacklightCompensation.swift
//  PTZ
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

/// Controls backlight compensation
/// Discovered in the original application's logs
public struct PTZBacklightCompensationState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "BacklightCompensation"
    public static let register: PTZRegister<PTZNone> = .init(0x02, 0x15)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}

