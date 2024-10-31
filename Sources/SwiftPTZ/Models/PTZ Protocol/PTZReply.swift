//
//  PTZReply.swift
//
//
//  Created by syan on 30/12/2023.
//

import Foundation

enum PTZReply: CustomStringConvertible {
    case ack
    case reset
    case fail
    case timeout
    case executed
    case notExecuted(error: CommandError)
    case specific(bytes: Bytes, content: any PTZSpecificReply)
    case state(bytes: Bytes, state: any PTZState)
    case unknown(bytes: Bytes)

    enum CommandError: UInt16, RawRepresentable, CaseIterable, CustomStringConvertible, PTZValue {
        static var `default`: PTZReply.CommandError { .unknown }
        case modeCondition      = 0x00
        case panMotorWarning    = 0x01
        case tiltMotorWarning   = 0x02
        case motorsWarning      = 0x03
        case syntaxError        = 0x10
        case bufferFull         = 0x11
        case commandNotDefined  = 0x12
        case unknown            = 0xFF
        
        var description: String {
            switch self {
            case .modeCondition:     return "Mode condition"
            case .panMotorWarning:   return "Pan motor warning"
            case .tiltMotorWarning:  return "Tilt motor warning"
            case .motorsWarning:     return "Pan and tilt motors warning"
            case .syntaxError:       return "Syntax error"
            case .bufferFull:        return "Buffer full"
            case .commandNotDefined: return "Command not defined"
            case .unknown:           return "Unknown"
            }
        }
    }
    
    init(message: PTZMessage) {
        if message.bytes == [0xA0] {
            self = .ack
        }
        else if message.bytes == [0xE0] {
            self = .reset
        }
        else if message.bytes == [0xF0] {
            self = .fail
        }
        else if message.bytes == [0x92, 0x40, 0x00] {
            self = .executed
        }
        else if message.bytes.starts(with: [0x93, 0x40, 0x01]) {
            self = .notExecuted(error: message.parseArgument(position: .raw8(3)))
        }
        else if let reply = Self.availableSpecificReplies.compactMap({ $0.init(message: message) }).first {
            self = .specific(bytes: message.bytes, content: reply)
        }
        else if let state = Self.availableStates.compactMap({ $0.init(message: message) }).first {
            self = .state(bytes: message.bytes, state: state)
        }
        else {
            self = .unknown(bytes: message.bytes)
        }
    }
    
    var bytes: Bytes {
        switch self {
        case .ack:                  return [0xA0]
        case .reset:                return [0xE0]
        case .fail:                 return [0xF0]
        case .timeout:              return [0xFF] // not real, defined for ease of use
        case .executed:             return [0x92, 0x40, 0x00]
        case .notExecuted(let e):   return [0x93, 0x40, 0x01, UInt8(e.rawValue)]
        case .specific(let b, _):   return b
        case .state(let b, _):      return b
        case .unknown(let b):       return b
        }
    }
    
    var isNotExecuted: Bool {
        if case .notExecuted = self {
            return true
        }
        return false
    }
    
    var specific: (any PTZSpecificReply)? {
        if case .specific(_, let s) = self {
            return s
        }
        return nil
    }
    
    var description: String {
        switch self {
        case .ack:                  return "ACK"
        case .reset:                return "RESET"
        case .fail:                 return "FAIL"
        case .timeout:              return "TIMEOUT"
        case .executed:             return "Executed"
        case .notExecuted(let e):   return "Not executed: \(e)"
        case .specific(_, let r):   return r.description
        case .state(_, let s):      return s.description
        case .unknown(let b):       return "Unknown(\(b.hexString)"
        }
    }
}

extension PTZReply: Equatable {
    static func == (lhs: PTZReply, rhs: PTZReply) -> Bool {
        return lhs.bytes == rhs.bytes
    }
}

#warning("remove this ASAP")
protocol PTZSpecificReply: CustomStringConvertible {
    init?(message: PTZMessage)
}

extension PTZReply {
    static var availableSpecificReplies: [any PTZSpecificReply.Type] {
        return [
            PTZReplyDrunkTestPhase.self,
            PTZReplyMotorStats.self,
            PTZReplyPosition.self,
            PTZReplyPreset.self,
        ]
    }
    
    static var availableStates: [any PTZState.Type] {
        return [
            PTZAutoExposureState.self,
            PTZAutoFocusState.self,
            PTZBacklightCompensationState.self,
            PTZBrightnessState.self,
            PTZCalibrationHueState.self, PTZCalibrationLuminanceState.self, PTZCalibrationSaturationState.self,
            PTZClockState.self,
            PTZColorsState.self,
            PTZContrastState.self,
            PTZDevModeState.self,
            PTZFocusState.self,
            PTZGainModeState.self, PTZEffectiveGainState.self, PTZRedGainState.self, PTZBlueGainState.self,
            PTZHelloState.self,
            PTZInvertedState.self,
            PTZIrisLevelState.self,
            PTZLedIntensityState.self,
            PTZLedState.self,
            PTZMireState.self,
            PTZNoiseReductionState.self,
            PTZPanState.self,
            PTZPowerState.self,
            PTZSaturationState.self,
            PTZSensorSmoothingState.self,
            PTZSharpnessState.self,
            PTZShutterSpeedState.self,
            PTZSleepTimeoutState.self,
            PTZTiltState.self,
            PTZVideoOutputState.self,
            PTZVignetteCorrectionState.self,
            PTZWhiteBalanceState.self,
            PTZWhiteBalanceTempState.self,
            PTZWhiteBalanceTintState.self,
            PTZWhiteLevelState.self,
            PTZWideDynamicRangeState.self,
            PTZZoomState.self,
        ]
    }
}
