//
//  PTZRequest.swift
//  
//
//  Created by syan on 30/12/2023.
//

import Foundation

protocol PTZRequest {
    var bytes: Bytes { get }
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

struct PTZRequestMove: PTZRequest {
    let bytes: Bytes

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

struct PTZRequestStopMove: PTZRequest {
    let bytes: Bytes

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

struct PTZPosition: Equatable {
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

extension PTZPosition: ExpressibleByIntegerLiteral {
    init(integerLiteral value: IntegerLiteralType) {
        self.value = value
    }
}

struct PTZRequestSetPosition: PTZRequest {
    let bytes: Bytes
    
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
    let bytes: Bytes
    
    init() {
        self.bytes = [0x82, 0x01, 0x50]
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
    let bytes: Bytes
    
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
    let bytes: Bytes
    
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
    let bytes: Bytes
    
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
    let bytes: Bytes
    
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
    let bytes: Bytes
    
    init() {
        self.bytes = [0x82, 0x45, 0x17]
    }
}

struct PTZRequestSetLed: PTZRequest {
    let bytes: Bytes
    
    init(on: Bool) {
        if on {
            self.bytes = [0x84, 0x41, 0x21, 0x02, 0x10]
        }
        else {
            self.bytes = [0x84, 0x41, 0x21, 0x00, 0x00]
        }
    }
}

struct PTZRequestSetStandByMode: PTZRequest {
    let bytes: Bytes
    
    init(on: Bool) {
        if on {
            self.bytes = [0x83, 0x41, 0x00, 0x12]
        }
        else {
            self.bytes = [0x83, 0x41, 0x00, 0x10]
        }
    }
}

struct PTZRequestEnableVideoOutput: PTZRequest {
    let bytes: Bytes
    
    init() {
        self.bytes = [0x83, 0x41, 0x13, 0x1a]
    }
}

struct PTZRequestSetShutterSpeed: PTZRequest {
    let bytes: Bytes
    
    enum Speed {
        case zero
    }
    
    init(speed: Speed) {
        switch speed {
        case .zero: self.bytes = [0x83, 0x42, 0x14, 0x00]
        }
    }
}

struct PTZRequestSetMuteState: PTZRequest {
    let bytes: Bytes
    
    enum State {
        case unmute
    }
    init(state: State) {
        switch state {
        case .unmute: self.bytes = [0x85, 0x41, 0x25, 0x08, 0x08, 0x08]
        }
    }
}

struct PTZRequestSetGain: PTZRequest {
    let bytes: Bytes
    
    enum Gain: UInt8 {
        case r = 0x42
        case b = 0x43
    }
    
    init(gain: Gain) {
        switch gain {
        // change auto gainr to 37 => 84 43 42 01 04
        case .r: self.bytes = [0x84, 0x43, 0x42, 0x01, 0x04]
        // change auto gainb to 33 => 84 43 43 01 00
        case .b: self.bytes = [0x84, 0x43, 0x43, 0x01, 0x00]
        }
    }
}

struct PTZRequestHello: PTZRequest {
    let bytes: Bytes
    
    init() {
        self.bytes = [0x82, 0x06, 0x77]
    }
}

func bootSequence() -> [PTZRequest] {
    return [
        PTZRequestSetStandByMode(on: false),
        PTZRequestSetLed(on: true),
        PTZRequestEnableVideoOutput(),
        PTZRequestSetShutterSpeed(speed: .zero),
        PTZRequestSetMuteState(state: .unmute),
        PTZRequestSetPosition(pan: .init(value: 0), tilt: .init(value: 0), zoom: .init(value: 0)),
        PTZRequestSetInvertMode(inverted: false),
        PTZRequestSetBrightness(brightness: .init(value: 11)),
        PTZRequestSetSaturation(saturation: .init(value: 6)),
        PTZRequestSetGain(gain: .r),
        PTZRequestSetGain(gain: .b),
        PTZRequestSetWhiteBalance(mode: .auto),
        PTZRequestSetBacklightCompensation(enabled: false)
    ]
}

func sleepSequence() -> [PTZRequest] {
    return [
        PTZRequestSetLed(on: false),
        PTZRequestSetStandByMode(on: true),
    ]
}

// 82 4c 19
// 82 6 77
// 82 6 7e
// 82 6 7f


/*
2:17.581 INFO     PCon: hd[0]: PcThreads: PC_ProcessMsg: component_id: "cam1" serial_properties { baud_rate: 9600 parity: PARITY_NONE data_bits: 8 stop_bits: 1 }
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Enter PC_SerialPropertiesCB for serial port on cam1
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Set baud rate to 9600
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Set parity to 3
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Set data bits to 8
12:22:17.581 INFO     PCon: hd[0]: PcSerial: PC: Set stop bits to 1
12:22:17.581 INFO     SMan: hd[0]: CameraVisca: DiscoverCamera()
12:22:17.581 DEBUG    SMan: hd[0]: CameraBase: Send 5 bytes: 81 9 0 2 ff
12:22:17.582 DEBUG    SMan: hd[0]: CameraBase: SM: WaitForNewCmdMsg: got message...
12:22:17.582 DEBUG    SMan: hd[0]: CameraBase: In: Command:
12:22:17.582 DEBUG    SMan: hd[0]: CameraBase: Have generic command
12:22:17.582 INFO     SMan: hd[0]: SrcMan: 81 09 00 02 FF
*/


