//
//  WhiteBalance.swift
//  
//
//  Created by syan on 05/07/2024.
//

import Foundation
import PTZMessaging

public enum PTZWhiteBalance: UInt16, PTZEnumValue {
    case auto      =  1
    case manual    =  4
    case temp2300K =  5
    case temp2856K =  6
    case temp3450K =  7
    case temp4230K =  8
    case temp5200K =  9
    case temp6504K = 10
    
    public var description: String {
        switch self {
        case .auto:      return "auto"
        case .manual:    return "manual"
        case .temp2300K: return "2300K"
        case .temp2856K: return "2856K"
        case .temp3450K: return "3450K"
        case .temp4230K: return "4230K"
        case .temp5200K: return "5200K"
        case .temp6504K: return "6504K"
        }
    }
    
    public static let `default`: Self = .auto
}

/// Controls the white balance
/// Discovered in the original appplication's logs
/// In `manual` mode you can adjust the colors using `PTZWhiteBalanceTempState` and `PTZWhiteBalanceTintState`
public struct PTZWhiteBalanceState: PTZParseableState, PTZReadable, PTZWritable {
    public static let name: String = "WhiteBalance"
    public static let register: PTZRegister<PTZNone> = .init(0x02, 0x12)

    public var value: PTZWhiteBalance
    
    public init(_ value: PTZWhiteBalance, for variant: PTZNone) {
        self.value = value
    }
}
