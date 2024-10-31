//
//  ShutterSpeed.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZShutterSpeed: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    // was called zero in ADB logs
    case auto    = 0x00
    // setting to either 0x01 or 0x02 reads back as 0x02. the decompiled source code shows that they are suppoed to be 1/50 and 1/60 respectively. a blinkind LED
    // test showed that they are both 1/50.
    case fps50   = 0x01
    case fps60   = 0x02
    // the values from 0x03 and above have been measured via an LED test as multiples of 1/50, and the actual values were eye-balled using
    // a DSLR configured in manual mode to have the light levels as 1/50. when taking a picture each time by halving the expo. time, it seemed
    // to match the next value for shutter speed here.
    case fps100  = 0x03
    case fps200  = 0x04
    case fps400  = 0x05
    case fps800  = 0x06
    case fps1600 = 0x07
    case fps3200 = 0x08

    var description: String {
        switch self {
        case .auto:    return "auto"
        case .fps50:   return "1/50"
        case .fps60:   return "1/60"
        case .fps100:  return "1/100"
        case .fps200:  return "1/200"
        case .fps400:  return "1/400"
        case .fps800:  return "1/800"
        case .fps1600: return "1/1600"
        case .fps3200: return "1/3200"
        }
    }
    
    static var `default`: PTZShutterSpeed { .auto }
}

struct PTZShutterSpeedState: PTZSingleValueState {
    static var name: String = "ShutterSpeed"
    static var register: (UInt8, UInt8) = (0x02, 0x14)
    
    var value: PTZShutterSpeed
    
    init(_ value: PTZShutterSpeed) {
        self.value = value
    }
}
