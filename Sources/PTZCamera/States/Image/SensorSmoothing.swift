//
//  SensorSmoothing.swift
//  PTZ
//
//  Created by syan on 21/10/2024.
//

import Foundation
import PTZMessaging

/// Controls the camera's integrated sensor subpixel "smoothing". Without it the image seems a bit crisper but some dead pixels appear
/// Discovered by fuzzing
public struct PTZSensorSmoothingState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "SensorSmoothing"
    public static let register: PTZRegister<PTZNone> = .init(0x01, 0x3B)

    public var value: PTZBool
    
    public init(_ value: PTZBool, for variant: PTZNone) {
        self.value = value
    }
}
