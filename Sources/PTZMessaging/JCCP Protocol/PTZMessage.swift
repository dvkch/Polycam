//
//  PTZMessage.swift
//  
//
//  Created by syan on 03/07/2024.
//

import Foundation

public struct PTZMessage {
    public let bytes: Bytes

    internal init(bytes: Bytes) {
        self.bytes = bytes
    }
}

public extension PTZMessage {
    static func receptionComplete(from bytes: Bytes) -> Bool {
        let messages = PTZMessage.messages(from: bytes)
        guard messages.allSatisfy(\.isValidLength) else { return false }
  
        if let first = messages.first, case .ack = PTZReply(message: first)  {
            return messages.count > 1
        }
        return true
    }
    
    static func messages(from bytes: Bytes) -> [PTZMessage] {
        return bytes
            .split(startFilter: { $0 >= 0x80 })
            .map { self.init(bytes: $0) }
    }
    
    static func replies(from bytes: Bytes) -> [PTZReply] {
        return PTZMessage.messages(from: bytes).map { PTZReply(message: $0) }
    }
}

private extension PTZMessage {
    enum Format {
        case regular
        case long
        case hello
    }
    
    var messageFormat: Format {
        if bytes.count >= 2 && bytes[0] == 0x8F && bytes[1] == 0x30 {
            return .hello
        }
        if bytes.count >= 1 && bytes[0] == 0x8F {
            return .long
        }
        return .regular
    }
    
    var isValidLength: Bool {
        return receivedLength == givenLength
    }
    
    var givenLength: Int {
        switch messageFormat {
        case .regular:  return Int(bytes[0] & 0x0F)
        case .long:     return Int(bytes[1])
        case .hello:    return Int(String(bytes[2], radix: 16), radix: 10)!
        }
    }
    
    var receivedLength: Int {
        switch messageFormat {
        case .regular:  return bytes.count - 1
        case .long:     return bytes.count - 1
        case .hello:    return bytes.count - 3
        }
    }
}

public extension PTZMessage {
    func isValidReply(_ command: (Byte, Byte)) -> Bool {
        guard isValidLength && receivedLength >= 2 else { return false }
        switch messageFormat {
        case .regular:  return Array(bytes[1..<3]) == [command.0, command.1]
        case .long:     return Array(bytes[2..<4]) == [command.0, command.1]
        case .hello:    return Array(bytes[3..<5]) == [command.1, command.0]
        }
    }
}

public extension PTZMessage {
    func parseArgument<V: PTZValue>(type: V.Type = V.self, position: PTZArgument.Position) -> V {
        switch position {
        case .single:
            if bytes.count == 4 {
                return V.init(ptzValue: UInt16(bytes[3]))
            }
            if bytes.count == 5 {
                return V.init(ptzValue: UInt16(bytes[3]) * 0x80 + UInt16(bytes[4]))
            }
            fatalError("There is no first argument here")
            
        case .raw8(let index):
            return V.init(ptzValue: UInt16(bytes[index]))

        case .raw16(let index):
            return V.init(ptzValue: UInt16(bytes[index]) << 8 + UInt16(bytes[index + 1]))

        case .custom(let hiIndex, let loIndex, let loRetainerIndex, let loRetainerMask):
            return V.init(from: bytes, loIndex: loIndex, hiIndex: hiIndex, loRetainerIndex: loRetainerIndex, loRetainerMask: loRetainerMask)
        }
    }
    
    func decodePackedData() -> [Int] {
        guard messageFormat == .hello else {
            fatalError("No packed data in this reply")
        }
        
        let packedData = Array(bytes[5...])
        return packedData.map { Int($0 - 0x30) }
    }
}

public extension PTZMessage {
    init(_ command: (Byte, Byte), _ singleArg: any PTZValue) {
        self.init(command, PTZArgument(singleArg, .single))
    }

    init(_ command: (Byte, Byte), _ args: (PTZArgument)...) {
        var bytes = Bytes()
        bytes.append(0x00)
        bytes.append(contentsOf: [command.0, command.1])
        
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
        self.bytes = bytes
    }
}
