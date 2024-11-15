//
//  DevMode.swift
//  PTZ
//
//  Created by syan on 20/10/2024.
//

import Foundation
import PTZMessaging

/// Controls the usage of more advanced features, such as `PTZGreyscaleState`, `PTZDrunkTestAction`, `PTZStatisticsState` and `PTZFocusAction`
/// Discovered by fuzzing
public struct PTZDevModeState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "DevMode"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x0B)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
