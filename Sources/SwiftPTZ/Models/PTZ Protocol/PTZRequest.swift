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
    var modeConditionRescueRequests: [any PTZRequest] { get }
}

protocol PTZGetRequest<Reply>: PTZRequest {
    associatedtype Reply: PTZSpecificReply
}

protocol PTZActionRequest: PTZRequest {
}

extension PTZRequest {
    var waitingTimeIfExecuted: TimeInterval { 0 }
    var modeConditionRescueRequests: [any PTZRequest] { [] }
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
            let hi = UInt8(arg.value.ptzValue >> 7)
            let lo = UInt8(arg.value.ptzValue & 0x7F)
            if hi > 0 {
                bytes.append(hi)
            }
            bytes.append(lo)
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
                    
                case .raw8(let index):
                    bytes.ensureLength(index + 1, filler: 0x00)
                    bytes[index] = Byte(arg.value.ptzValue)

                case .raw16(let index):
                    bytes.ensureLength(index + 2, filler: 0x00)
                    bytes[index]     = Byte(arg.value.ptzValue >> 8)
                    bytes[index + 1] = Byte(arg.value.ptzValue & 0xFF)

                case .single:
                    fatalError("Unsupported arguments combination")
                }
            }
        }
        
        bytes[0] = 0x80 + Byte(bytes.count - 1)
        return bytes
    }
}