//
//  VideoOutput.swift
//  PTZ
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public enum PTZVideoOutput: UInt16, PTZEnumValue {
    case unknown00         = 0x00
    case unknown0A         = 0x0a
    case resolution720p60  = 0x10
    case resolution1080p60 = 0x1a
    
    public var description: String {
        switch self {
        case .unknown00:         return "Unknown(00)"
        case .unknown0A:         return "Unknown(0A)"
        case .resolution720p60:  return "720p60"
        case .resolution1080p60: return "1080p60"
        }
    }
    
    public static var `default`: PTZVideoOutput { .resolution1080p60 }
}

/// Switch video mode
/// Discovered in the original application's logs
public struct PTZVideoOutputState: PTZParseableState, PTZReadable, PTZWriteable {
    public static var name: String = "VideoOutput"
    public static var register: (UInt8, UInt8) = (0x01, 0x13)
    
    public var value: PTZVideoOutput
    
    public init(_ value: PTZVideoOutput, for variant: PTZNone) {
        self.value = value
    }
    
    public func set() -> PTZRequest {
        return .init(name: "Set \(self)", message: setMessage(), waitingTimeIfExecuted: 6)
    }
}
