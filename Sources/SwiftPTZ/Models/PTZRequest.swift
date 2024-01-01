//
//  PTZRequest.swift
//  
//
//  Created by syan on 30/12/2023.
//

import Foundation

protocol PTZRequest {
    var bytes: [UInt8] { get }
}

extension PTZRequest {
    var stringRepresentation: String {
        return bytes.stringRepresentation
    }
    var validLength: Bool {
        let messageLength = bytes.count - 1
        let expectedLength = (bytes.first ?? 0x80) & 0x0F
        return messageLength == expectedLength
    }
}

struct PTZRequestMove {
    let bytes: [UInt8]

    enum Direction: UInt8 {
        case left      = 0x11
        case right     = 0x01
        case up        = 0x03
        case down      = 0x04
        case zoomIn    = 0x0C
        case zoomOut   = 0x0D
        
        private var accelerationValues: [UInt8] {
            switch self {
            case .left, .right, .up, .down:
                return [0x11, 0x13, 0x15, 0x17, 0x19]
            case .zoomIn, .zoomOut:
                return [0x00, 0x01, 0x02]
            }
        }
        
        func accelerationValue(fromPercent percent: Int) -> UInt8 {
            let index = percent * accelerationValues.count / 100
            return accelerationValues[index]
        }
    }
    
    init(direction: Direction, accelerationPercent: Int) {
        self.bytes = [
            0x83,
            0x45,
            direction.rawValue,
            direction.accelerationValue(fromPercent: accelerationPercent)
        ]
    }
}

struct PTZRequestStopMove {
    let bytes: [UInt8]

    enum Direction: UInt8 {
        case horizontal = 0x02
        case vertical   = 0x05
        case zoom       = 0x0E
    }
    
    init(direction: Direction) {
        self.bytes = [
            0x82,
            0x45,
            direction.rawValue
        ]
    }
}

struct PTZPosition {
    enum Kind {
        case pan
        case tilt
        case zoom
        
        var scale: (multiplier: Double, offset: Double) {
            switch self {
            case .pan:  return (multiplier: 0.02,      offset: 1000)
            case .tilt: return (multiplier: 0.005,     offset:  250)
            case .zoom: return (multiplier: 0.0217246, offset: 1146)
            }
        }
    }
    
    let value: Int
    init(value: Int) {
        self.value = value
    }

    static var minValue: Int {
        return -50_000
    }
    static var maxValue: Int {
        return 50_000
    }

    var isValid: Bool {
        return value >= type(of: self).minValue && value <= type(of: self).maxValue
    }
    
    var clamped: Int {
        return Swift.min(type(of: self).maxValue, Swift.max(type(of: self).minValue, value))
    }
    
    func requestValue(kind: Kind) -> UInt16 {
        let value = Double(self.clamped) * kind.scale.multiplier + kind.scale.offset
        return UInt16(value.rounded())
    }
    
    init(kind: Kind, value: UInt16) {
        self.value = Int((Double(value) - kind.scale.offset) / kind.scale.multiplier)
    }
}

struct PTZRequestSetPosition: PTZRequest {
    let bytes: [UInt8]
    
    init(pan: PTZPosition, tilt: PTZPosition, zoom: PTZPosition) {
        let panValue  =  pan.requestValue(kind: .pan)
        let tiltValue = tilt.requestValue(kind: .tilt)
        let zoomValue = zoom.requestValue(kind: .zoom)
        
        let panBytes  = panValue.requestBytes
        let tiltBytes = tiltValue.requestBytes
        let zoomBytes = zoomValue.requestBytes

        self.bytes = [
            0x8D,
            0x41,
            0x51,
            (panBytes.loRetainer ? 0x4 : 0) + (tiltBytes.loRetainer ? 0x20 : 0),
            0x00,
            panBytes.hi,
            panBytes.lo,
            0x00,
            tiltBytes.hi,
            tiltBytes.lo,
            0x03,
            (zoomBytes.loRetainer ? 0x2 : 0),
            zoomBytes.hi,
            zoomBytes.lo
        ]
    }
}

struct PTZRequestGetPosition: PTZRequest {
    let bytes: [UInt8]
    
    init() {
        self.bytes = [
            0x82,
            0x01,
            0x50
        ]
    }
}

struct PTZRequestSetBacklightCompensation: PTZRequest {
    let bytes: [UInt8]
    
    init(enabled: Bool) {
        self.bytes = [
            0x83,
            0x42,
            0x15,
            enabled ? 0x01 : 0x00
        ]
    }
}

struct PTZBrightness {
    let value: Int
    init(value: Int) {
        self.value = value
    }

    static var minValue: Int {
        return 1
    }
    static var maxValue: Int {
        return 20
    }

    var isValid: Bool {
        return value >= type(of: self).minValue && value <= type(of: self).maxValue
    }
    
    var clamped: Int {
        return Swift.min(type(of: self).maxValue, Swift.max(type(of: self).minValue, value))
    }
    
    var requestValue: UInt16 {
        let value = 117 + self.clamped
        return UInt16(value)
    }
}

struct PTZRequestSetBrightness: PTZRequest {
    let bytes: [UInt8]
    
    init(brightness: PTZBrightness) {
        let brightnessBytes = brightness.requestValue.requestBytes
        
        if brightnessBytes.loRetainer {
            self.bytes = [
                0x84,
                0x41,
                0x33,
                0x01,
                brightnessBytes.lo
            ]
        }
        else {
            self.bytes = [
                0x83,
                0x41,
                0x33,
                brightnessBytes.lo
            ]
        }
    }
}

struct PTZRequestSetInvertMode: PTZRequest {
    let bytes: [UInt8]
    
    init(inverted: Bool) {
        self.bytes = [
            0x83,
            0x41,
            0x3E,
            inverted ? 0x01 : 0x00
        ]
    }
}

struct PTZSaturation {
    let value: Int
    init(value: Int) {
        self.value = value
    }

    static var minValue: Int {
        return 1
    }
    static var maxValue: Int {
        return 11
    }

    var isValid: Bool {
        return value >= type(of: self).minValue && value <= type(of: self).maxValue
    }
    
    var clamped: Int {
        return Swift.min(type(of: self).maxValue, Swift.max(type(of: self).minValue, value))
    }
    
    var requestValue: UInt16 {
        let value = 122 + self.clamped
        return UInt16(value)
    }
}

struct PTZRequestSetSaturation: PTZRequest {
    let bytes: [UInt8]
    
    init(saturation: PTZSaturation) {
        let saturationBytes = saturation.requestValue.requestBytes
        
        if saturationBytes.loRetainer {
            self.bytes = [
                0x84,
                0x43,
                0x3e,
                0x01,
                saturationBytes.lo
            ]
        }
        else {
            self.bytes = [
                0x83,
                0x43,
                0x3e,
                saturationBytes.lo
            ]
        }
    }
}

struct PTZRequestSetWhiteBalance: PTZRequest {
    let bytes: [UInt8]
    
    enum Mode: Int {
        case auto      =  1
        case manual    =  4
        case temp2300K =  5
        case temp2856K =  6
        case temp3450K =  7
        case temp4230K =  8
        case temp5200K =  9
        case temp6504K = 10
    }

    init(mode: Mode) {
        self.bytes = [
            0x83,
            0x42,
            0x12,
            UInt8(mode.rawValue)
        ]
    }
}

struct PTZRequestStartManualWhiteBalanceCalibration: PTZRequest {
    let bytes: [UInt8]
    
    init() {
        self.bytes = [
            0x82,
            0x45,
            0x17
        ]
    }
}

struct PTZRequestSleep: PTZRequest {
    let bytes: [UInt8]
    
    enum Step {
        case step1TurnLedOff
        case step2StandByModeOn
    }
    init(step: Step) {
        switch step {
        case .step1TurnLedOff:    self.bytes = [0x84, 0x41, 0x21, 0x00, 0x00]
        case .step2StandByModeOn: self.bytes = [0x83, 0x41, 0x00, 0x12]
        }
    }
}


//
struct PTZRequestWake: PTZRequest {
    let bytes: [UInt8]
    
    enum Step {
        case step1StandByModeOff
        case step2TurnLedOn
        case step3EnableVideoOutput
        case step4SetShutterSpeed
        case step5DisableMuteState
        // PTZRequestSetPosition
        // PTZRequestSetInvertMode
        // PTZRequestSetBrightness
        // PTZRequestSetSaturation
        // change auto gainr to 37 => 84 43 42 01 04
        // change auto gainb to 33 => 84 43 43 01 00
        // PTZRequestSetWhiteBalance
        // PTZRequestSetBacklightCompensation
    }
    init(step: Step) {
        switch step {
        case .step1StandByModeOff:      self.bytes = [0x83, 0x41, 0x00, 0x10]
        case .step2TurnLedOn:           self.bytes = [0x84, 0x41, 0x21, 0x02, 0x10]
        case .step3EnableVideoOutput:   self.bytes = [0x83, 0x41, 0x13, 0x1a]
        case .step4SetShutterSpeed:     self.bytes = [0x83, 0x42, 0x14, 0x00]
        case .step5DisableMuteState:    self.bytes = [0x85, 0x41, 0x25, 0x08, 0x08, 0x08]
        }
    }
}
