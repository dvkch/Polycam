//
//  WhiteBalance.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation

enum PTZWhiteBalance: UInt16, CustomStringConvertible, CaseIterable, PTZValue {
    case auto      =  1
    case manual    =  4
    case temp2300K =  5
    case temp2856K =  6
    case temp3450K =  7
    case temp4230K =  8
    case temp5200K =  9
    case temp6504K = 10
    
    var description: String {
        switch self {
        case .auto: return "auto"
        case .manual: return "manual"
        case .temp2300K: return "2300K"
        case .temp2856K: return "2856K"
        case .temp3450K: return "3450K"
        case .temp4230K: return "4230K"
        case .temp5200K: return "5200K"
        case .temp6504K: return "6504K"
        }
    }
    
    static var `default`: PTZWhiteBalance { .auto }
}

struct PTZRequestSetWhiteBalance: PTZRequest {
    let mode: PTZWhiteBalance
    var bytes: Bytes { buildBytes([0x42, 0x12], mode) }
    var description: String { "Set white balance to \(mode.description)" }
}

struct PTZRequestStartManualWhiteBalanceCalibration: PTZRequest {
    var bytes: Bytes { buildBytes([0x45, 0x17]) }
    var waitingTimeIfExecuted: TimeInterval { 2 }
    var description: String { "Start manual white balance calibration" }
}

struct PTZRequestGetWhiteBalance: PTZGetRequest {
    typealias Reply = PTZReplyWhiteBalance
    var bytes: Bytes { buildBytes([0x02, 0x12]) }
    var description: String { "Get white balance" }
}

struct PTZReplyWhiteBalance: PTZReply {
    let mode: PTZWhiteBalance

    init?(message: PTZMessage) {
        guard message.isValidReply([0x42, 0x12]) else { return nil }
        self.mode = message.parseArgument(position: .single)
    }
    
    var description: String {
        return "WhiteBalance(\(mode.description))"
    }
}
