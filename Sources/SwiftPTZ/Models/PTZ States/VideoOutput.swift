//
//  VideoOutput.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZVideoOutput: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case unknown00         = 0x00
    case unknown0A         = 0x0a
    case resolution720p60  = 0x10
    case resolution1080p60 = 0x1a
    
    var description: String {
        switch self {
        case .unknown00:         return "Unknown(00)"
        case .unknown0A:         return "Unknown(0A)"
        case .resolution720p60:  return "720p60"
        case .resolution1080p60: return "1080p60"
        }
    }
    
    static var `default`: PTZVideoOutput { .resolution1080p60 }
}

struct PTZVideoOutputState: PTZSingleValueState {
    static var name: String = "VideoOutput"
    static var register: (UInt8, UInt8) = (0x01, 0x13)
    
    var value: PTZVideoOutput
    
    init(_ value: PTZVideoOutput) {
        self.value = value
    }
    
    var waitingTimeIfExecuted: TimeInterval { 6 }
}
