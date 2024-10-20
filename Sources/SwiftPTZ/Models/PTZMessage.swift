//
//  PTZMessage.swift
//  
//
//  Created by syan on 03/07/2024.
//

import Foundation

struct PTZMessage {
    static func receptionComplete(from bytes: Bytes) -> Bool {
        let messages = PTZMessage.messages(from: bytes)
        guard messages.allSatisfy(\.isValidLength) else { return false }
  
        if let first = messages.first, PTZReplyAck(message: first) != nil  {
            return messages.count > 1
        }
        return true
    }
    
    static func messages(from bytes: Bytes) -> [PTZMessage] {
        return bytes
            .split(startFilter: { $0 >= 0x80 })
            .map { self.init(bytes: $0) }
    }
    
    let bytes: Bytes

    private init(bytes: Bytes) {
        self.bytes = bytes
    }
}

extension PTZMessage {
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
    
    private var givenLength: Int {
        switch messageFormat {
        case .regular:  return Int(bytes[0] & 0x0F)
        case .long:     return Int(bytes[1])
        case .hello:    return Int(String(bytes[2], radix: 16), radix: 10)!
        }
    }
    
    private var receivedLength: Int {
        switch messageFormat {
        case .regular:  return bytes.count - 1
        case .long:     return bytes.count - 1
        case .hello:    return bytes.count - 3
        }
    }
    
    func isValidReply(_ command: Bytes) -> Bool {
        guard isValidLength && receivedLength >= 2 else { return false }
        switch messageFormat {
        case .regular:  return Array(bytes[1..<3]) == command
        case .long:     return Array(bytes[2..<4]) == command
        case .hello:    return Array(bytes[3..<5]) == command.reversed()
        }
    }
}

extension PTZMessage {
    func parseArgument<V: PTZValue>(type: V.Type = V.self, position: PTZArgument.Position) -> V {
        switch position {
        case .single:
            if bytes.count == 4 {
                return V.init(ptzValue: UInt16(bytes[3]))
            }
            if bytes.count == 5 {
                return V.init(ptzValue: UInt16(bytes[3]) + 0x7F + UInt16(bytes[4]))
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

extension PTZMessage {
    static var availableReplies: [any PTZReply.Type] {
        return [
            PTZReplyAck.self, PTZReplyReset.self, PTZReplyFail.self,
            PTZReplyExecuted.self, PTZReplyNotExecuted.self,

            PTZReplyAutoExposure.self,
            PTZReplyAutoFocus.self,
            PTZReplyBacklightCompensation.self,
            PTZReplyBrightness.self,
            PTZReplyClock.self,
            PTZReplyDevMode.self,
            PTZReplyDrunkTestPhase.self,
            PTZReplyFocus.self,
            PTZReplyGainMode.self, PTZReplyEffectiveGain.self, PTZReplyRedGain.self, PTZReplyBlueGain.self,
            PTZReplyHelloMPTZ11.self,
            PTZReplyInvertedMode.self,
            PTZReplyIrisLevel.self,
            PTZReplyLedMode.self,
            PTZReplyMireMode.self,
            PTZReplyPan.self,
            PTZReplyPosition.self,
            PTZReplyPreset.self,
            PTZReplySaturation.self,
            PTZReplySharpness.self,
            PTZReplyShutterSpeed.self,
            PTZReplyStandbyMode.self,
            PTZReplyTilt.self,
            PTZReplyVideoOutputMode.self,
            PTZReplyVolume.self,
            PTZReplyWhiteBalance.self,
            PTZReplyWhiteBalanceTemp.self,
            PTZReplyWhiteBalanceTint.self,
            PTZReplyWhiteLevel.self,
            PTZReplyZoom.self,
        ]
    }
    
    static func replies(from bytes: Bytes, allowed: [any PTZReply.Type] = availableReplies) -> [any PTZReply] {
        let messages = PTZMessage.messages(from: bytes)
        return messages.map { message in
            allowed.compactMap({ $0.init(message: message) }).first ?? PTZReplyUnknown(message: message)
        }
    }

}
