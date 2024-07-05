//
//  PTZRequest.swift
//  
//
//  Created by syan on 30/12/2023.
//

import Foundation

protocol PTZRequest: CustomStringConvertible {
    var bytes: Bytes { get }
}

extension PTZRequest {
    var stringRepresentation: String {
        return bytes.stringRepresentation
    }
    var validLength: Bool {
        let messageLength = bytes.count - 1
        let expectedLength = Int(bytes.first ?? 0) - 0x80
        return messageLength == expectedLength
    }
    
    fileprivate func buildBytes(_ command: Bytes, _ singleArg: any PTZValue) -> Bytes {
        return self.buildBytes(command, PTZArgument(value: singleArg, position: .single))
    }

    fileprivate func buildBytes(_ command: Bytes, _ args: (PTZArgument)...) -> Bytes {
        var bytes = Bytes()
        bytes.append(0x00)
        bytes.append(contentsOf: command)
        
        if args.count == 1, let arg = args.first, case .single = arg.position {
            let argBytes = arg.value.ptzValue.requestBytes
            if argBytes.loRetainer {
                bytes.append(contentsOf: [0x01, argBytes.lo])
            }
            else {
                bytes.append(contentsOf: [argBytes.lo])
            }
        }
        else {
            for arg in args {
                switch arg.position {
                case .custom(let hiIndex, let loIndex, let loRetainerIndex, let loRetainerMask):
                    let highestIndex = [hiIndex, loIndex, loRetainerIndex].max()!
                    bytes.ensureLength(highestIndex + 1, filler: 0x00)

                    let ptzValue = arg.value.ptzValue.requestBytes
                    bytes[hiIndex] = ptzValue.hi
                    bytes[loIndex] = ptzValue.lo
                    bytes[loRetainerIndex] += loRetainerMask * (ptzValue.loRetainer ? 1 : 0)
                    
                case .index(let index):
                    bytes.ensureLength(index + 1, filler: 0x00)
                    bytes[index] = UInt8(arg.value.ptzValue)

                case .single:
                    fatalError("Unsupported arguments combination")
                }
            }
        }
        
        bytes[0] = 0x80 + UInt8(bytes.count - 1)
        return bytes
    }
}

struct PTZRequestHello: PTZRequest {
    var bytes: Bytes {
        // 82 06 77
        // 82 06 7e
        // 82 06 7f
        return buildBytes([0x06, 0x77])
    }

    var description: String {
        return "Hello"
    }
}

struct PTZRequestMove: PTZRequest {
    let bytes: Bytes
    private let direction: Direction
    private let accelerationPercent: Int

    enum Direction: UInt8, CustomStringConvertible {
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
        
        var description: String {
            switch self {
            case .left:     return "left"
            case .right:    return "right"
            case .up:       return "up"
            case .down:     return "down"
            case .zoomIn:   return "zoom+"
            case .zoomOut:  return "zoom-"
            }
        }
    }
    
    init(direction: Direction, accelerationPercent: Int) {
        self.direction = direction
        self.accelerationPercent = accelerationPercent
        self.bytes = [
            0x83,
            0x45,
            direction.rawValue,
            direction.accelerationValue(fromPercent: accelerationPercent)
        ]
    }
    
    var description: String {
        return "Move \(direction.description), acceleration \(accelerationPercent)%"
    }
}

struct PTZRequestStopMove: PTZRequest {
    let bytes: Bytes
    private let direction: Direction

    enum Direction: UInt8, CustomStringConvertible {
        case horizontal = 0x02
        case vertical   = 0x05
        case zoom       = 0x0E
        
        var description: String {
            switch self {
            case .horizontal:   return "horizontal"
            case .vertical:     return "vertical"
            case .zoom:         return "zoom"
            }
        }
    }
    
    init(direction: Direction) {
        self.direction = direction
        self.bytes = [
            0x82,
            0x45,
            direction.rawValue
        ]
    }
    
    var description: String {
        return "Stop moving \(direction.description)"
    }
}

struct PTZRequestSetPosition: PTZRequest {
    let pan: PTZPositionPan
    let tilt: PTZPositionTilt
    let zoom: PTZPositionZoom
    
    var bytes: Bytes {
        return buildBytes(
            [0x41, 0x51],
            PTZArgument(value: pan,  position: .custom(hiIndex:  5, loIndex:  6, loRetainerIndex:  3, loRetainerMask: 0x04)),
            PTZArgument(value: tilt, position: .custom(hiIndex:  8, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20)),
            PTZArgument(value: zoom, position: .custom(hiIndex: 12, loIndex: 13, loRetainerIndex: 11, loRetainerMask: 0x02)),
            PTZArgument(value: PTZInt(rawValue: 0x03), position: .index(10))
        )
    }
    
    var description: String {
        return "Move to \(pan.rawValue), \(tilt.rawValue), \(zoom.rawValue)"
    }
}

struct PTZRequestGetPosition: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x50]) }
    var description: String { "Get position" }
}

struct PTZRequestSetBacklightCompensation: PTZRequest {
    let enabled: Bool
    var bytes: Bytes { buildBytes([0x42, 0x15], PTZBool(rawValue: enabled)) }
    var description: String { "Set backlight compensation \(enabled.onOffString)" }
}

struct PTZRequestSetBrightness: PTZRequest {
    let brightness: PTZBrightness
    var bytes: Bytes { buildBytes([0x41, 0x33], brightness) }
    var description: String { "Set brightness to \(brightness.rawValue)" }
}

struct PTZRequestGetBrightness: PTZRequest {
    var bytes: Bytes { buildBytes([0x01, 0x33]) }
    var description: String { "Get Brightness" }
}

struct PTZRequestSetInvertMode: PTZRequest {
    let inverted: Bool
    var bytes: Bytes { buildBytes([0x41, 0x3e], PTZBool(rawValue: inverted)) }
    var description: String { "Set inverted mode \(inverted.onOffString)" }
}

struct PTZRequestSetSaturation: PTZRequest {
    let saturation: PTZSaturation
    var bytes: Bytes { buildBytes([0x43, 0x3e], saturation) }
    var description: String { "Set saturation to \(saturation.rawValue)" }
}

struct PTZRequestSetWhiteBalance: PTZRequest {
    let mode: PTZWhiteBalance
    var bytes: Bytes { buildBytes([0x42, 0x12], mode) }
    var description: String { "Set white balance to \(mode.description)" }
}

struct PTZRequestStartManualWhiteBalanceCalibration: PTZRequest {
    var bytes: Bytes { buildBytes([0x45, 0x15]) }
    var description: String { "Start manual white balance calibration" }
}

struct PTZRequestSetLed: PTZRequest {
    let state: PTZLed
    #warning("TODO: arg0 should be sent on 2 bytes always....")
    var bytes: Bytes { buildBytes([0x41, 0x21], state) }
    var description: String { "Set LED \(state.description)" }
}

struct PTZRequestSetStandByMode: PTZRequest {
    let state: PTZStandByMode
    var bytes: Bytes { buildBytes([0x41, 0x00], state) }
    var description: String { "Set standby mode \(state.description)" }
}

struct PTZRequestSetVideoOutputMode: PTZRequest {
    let state: PTZVideoOutput
    var bytes: Bytes { buildBytes([0x41, 0x13], state) }
    var description: String { "Set video output \(state.description)" }
}

struct PTZRequestSetShutterSpeed: PTZRequest {
    let speed: PTZShutterSpeed
    var bytes: Bytes { buildBytes([0x42, 0x14], speed) }
    var description: String { "Set shutter speed to \(speed.description)" }
}

struct PTZRequestSetMuteState: PTZRequest {
    let state: PTZMuteState
    var bytes: Bytes {
        buildBytes(
            [0x41, 0x25], 
            .init(value: state, position: .index(3)),
            .init(value: state, position: .index(4)),
            .init(value: state, position: .index(5))
        )
    }
    var description: String { "Set mute state to \(state.description)" }
}

struct PTZRequestSetRedGain: PTZRequest {
    let gain: PTZGain
    var bytes: Bytes { buildBytes([0x43, 0x42], gain) }
    var description: String { "Set red gain to \(gain.rawValue)" }
}

struct PTZRequestSetBlueGain: PTZRequest {
    let gain: PTZGain
    var bytes: Bytes { buildBytes([0x43, 0x43], gain) }
    var description: String { "Set red gain to \(gain.rawValue)" }
}

func bootSequence() -> [PTZRequest] {
    return [
        PTZRequestSetStandByMode(state: .off),
        PTZRequestSetLed(state: .on),
        PTZRequestSetVideoOutputMode(state: .on),
        PTZRequestSetShutterSpeed(speed: .zero),
        PTZRequestSetMuteState(state: .unmute),
        PTZRequestSetPosition(pan: .init(rawValue: 0), tilt: .init(rawValue: 0), zoom: .init(rawValue: 0)),
        PTZRequestSetInvertMode(inverted: false),
        PTZRequestSetBrightness(brightness: .init(rawValue: 11)),
        PTZRequestSetSaturation(saturation: .init(rawValue: 6)),
        PTZRequestSetRedGain(gain: .init(rawValue: 37)),
        PTZRequestSetBlueGain(gain: .init(rawValue: 33)),
        PTZRequestSetWhiteBalance(mode: .auto),
        PTZRequestSetBacklightCompensation(enabled: false)
    ]
}

func sleepSequence() -> [PTZRequest] {
    return [
        PTZRequestSetLed(state: .off),
        PTZRequestSetStandByMode(state: .on),
    ]
}

// 82 4c 19

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

/*

01 50 => Get position
06 77 => Hello
41 00 => Set standby
41 13 => Set video output
41 21 => Set LED
41 25 => Set mute
41 33 => Set brightness
41 3E => Set invert mode
41 51 => Move to precise position
42 12 => Set white balance
42 14 => Set shutter speed
42 15 => Set backlight compensation
43 3E => Set saturation
43 42 => Set R gain
43 43 => Set B gain
45 17 => Start white balance calibration
45 xx => Move continuously in/Stop for direction xx

*/
