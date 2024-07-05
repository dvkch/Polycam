//
//  PTZRequest.swift
//  
//
//  Created by syan on 30/12/2023.
//

import Foundation

protocol PTZRequest: CustomStringConvertible {
    var bytes: Bytes { get }
    var waitingTimeIfExecuted: TimeInterval { get }
}

extension PTZRequest {
    var waitingTimeIfExecuted: TimeInterval { 0 }
}

extension PTZRequest {
    var validLength: Bool {
        let messageLength = bytes.count - 1
        let expectedLength = Int(bytes.first ?? 0) - 0x80
        return messageLength == expectedLength
    }
    
    func buildBytes(_ command: Bytes, _ singleArg: any PTZValue) -> Bytes {
        return self.buildBytes(command, PTZArgument(singleArg, .single))
    }

    func buildBytes(_ command: Bytes, _ args: (PTZArgument)...) -> Bytes {
        var bytes = Bytes()
        bytes.append(0x00)
        bytes.append(contentsOf: command)
        
        if args.count == 1, let arg = args.first, case .single = arg.position {
            #warning("TODO: try sending with a fixed length, the code would be simpler if it worked")
            let argBytes = arg.value.ptzBytes
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

                    let ptzValue = arg.value.ptzBytes
                    bytes[hiIndex] = ptzValue.hi
                    bytes[loIndex] = ptzValue.lo
                    bytes[loRetainerIndex] += loRetainerMask * (ptzValue.loRetainer ? 1 : 0)
                    
                case .index(let index):
                    bytes.ensureLength(index + 1, filler: 0x00)
                    bytes[index] = Byte(arg.value.ptzValue)

                case .single:
                    fatalError("Unsupported arguments combination")
                }
            }
        }
        
        bytes[0] = 0x80 + Byte(bytes.count - 1)
        return bytes
    }
}

#warning("TODO: finish reorganizing remaining commands")

struct PTZRequestMove: PTZRequest {
    let bytes: Bytes
    private let direction: Direction
    private let accelerationPercent: Int

    enum Direction: Byte, CustomStringConvertible {
        case left      = 0x11
        case right     = 0x01
        case up        = 0x03
        case down      = 0x04
        case zoomIn    = 0x0C
        case zoomOut   = 0x0D
        
        private var accelerationValues: Bytes {
            switch self {
            case .left, .right, .up, .down:
                return [0x11, 0x13, 0x15, 0x17, 0x19]
            case .zoomIn, .zoomOut:
                return [0x00, 0x01, 0x02]
            }
        }
        
        func accelerationValue(fromPercent percent: Int) -> Byte {
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

    enum Direction: Byte, CustomStringConvertible {
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

func bootSequence() -> [PTZRequest] {
    return [
        PTZRequestSetStandbyMode(mode: .off),
        PTZRequestSetLedMode(mode: .on),
        PTZRequestSetVideoOutputMode(mode: .on),
        PTZRequestSetShutterSpeed(speed: .zero),
        PTZRequestSetVolume(volume: .unmute),
        PTZRequestSetPosition(pan: .init(rawValue: 0), tilt: .init(rawValue: 0), zoom: .init(rawValue: 0)),
        PTZRequestSetInvertedMode(enabled: false),
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
        PTZRequestSetLedMode(mode: .off),
        PTZRequestSetStandbyMode(mode: .on),
    ]
}

