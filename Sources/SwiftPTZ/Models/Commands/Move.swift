//
//  Move.swift
//
//
//  Created by syan on 15/07/2024.
//

import Foundation

enum PTZPanTiltSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x11
    case speed2 = 0x13
    case speed3 = 0x15
    case speed4 = 0x17
    case speed5 = 0x19
    static var `default`: PTZPanTiltSpeed { .speed1 }
    
    var description: String {
        switch self {
        case .speed1: return "20%"
        case .speed2: return "40%"
        case .speed3: return "60%"
        case .speed4: return "80%"
        case .speed5: return "100%"
        }
    }
}

enum PTZZoomSpeed: UInt16, CaseIterable, CustomStringConvertible, PTZValue {
    case speed1 = 0x00
    case speed2 = 0x01
    case speed3 = 0x02
    static var `default`: PTZZoomSpeed { .speed1 }

    var description: String {
        switch self {
        case .speed1: return "30%"
        case .speed2: return "60%"
        case .speed3: return "100%"
        }
    }
}

enum PTZDirection: Byte, CaseIterable, CustomStringConvertible {
    case right     = 0x00
    case left      = 0x01
    case panStop   = 0x02
    case up        = 0x03
    case down      = 0x04
    case tiltStop  = 0x05
    case zoomIn    = 0x0C
    case zoomOut   = 0x0D
    case zoomStop  = 0x0E
    #warning("try this again")
    // 0x09, 0x0A and 0x0B might be for focus +/-/stop, but the camera replies with a mode condition error

    var description: String {
        switch self {
        case .right:    return "pan right"
        case .left:     return "pan left"
        case .panStop:  return "pan stop"
        case .up:       return "tilt up"
        case .down:     return "tilt down"
        case .tiltStop: return "tilt stop"
        case .zoomIn:   return "zoom+"
        case .zoomOut:  return "zoom-"
        case .zoomStop: return "zoom stop"
        }
    }
}

struct PTZRequestSetMove: PTZRequest {
    let direction: PTZDirection
    let panTiltSpeed: PTZPanTiltSpeed
    let zoomSpeed: PTZZoomSpeed

    var bytes: Bytes {
        if direction == .panStop || direction == .tiltStop || direction == .zoomStop {
            buildBytes([0x45, direction.rawValue])
        }
        else if direction == .zoomIn || direction == .zoomOut {
            buildBytes([0x45, direction.rawValue], .init(zoomSpeed, .single))
        }
        else {
            buildBytes([0x45, direction.rawValue], .init(panTiltSpeed, .single))
        }
    }
    
    var description: String {
        if direction == .panStop || direction == .tiltStop || direction == .zoomStop {
            return "Set move \(direction.description)"
        }
        else if direction == .zoomIn || direction == .zoomOut {
            return "Set move \(direction.description), \(zoomSpeed) speed"
        }
        else {
            return "Set move \(direction.description), \(panTiltSpeed) speed"
        }
    }
}
