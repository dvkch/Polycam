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

struct PTZWhiteBalanceState: PTZSingleValueState {
    static var name: String = "WhiteBalance"
    static var register: (UInt8, UInt8) = (0x02, 0x12)

    var value: PTZWhiteBalance
    
    init(_ value: PTZWhiteBalance) {
        self.value = value
    }
}

struct PTZWhiteBalanceCalibrationAction: PTZWriteable {
    static var name: String { "WhiteBalanceCalibration" }
    let variant: PTZNone
    var value: PTZNone
    
    init(_ value: PTZNone = .init(), for variant: PTZNone = .init()) {
        self.variant = variant
        self.value = value
    }

    func set() -> PTZRequest {
        return .init(name: "Start \(description)", message: .init((0x45, 0x17)), waitingTimeIfExecuted: 2)
    }
}
