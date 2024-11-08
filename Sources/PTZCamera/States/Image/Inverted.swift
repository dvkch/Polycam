//
//  Inverted.swift
//  PTZ
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

/// Invert the image top/down
/// Discovered in the original application's logs
public struct PTZInvertedState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "Inverted"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x3E)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
