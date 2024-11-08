//
//  Statistics.swift
//  PTZ
//
//  Created by syan on 23/10/2024.
//

import Foundation
import PTZMessaging

public enum PTZStatisticsGroup: UInt8, PTZVariant {
    case unknownAndNone = 0
    case focusAndZoom   = 1
    case noneAndIris    = 2
    case panAndTilt     = 3

    public var description: String {
        "\(names.0)/\(names.1)"
    }
    fileprivate var names: (String, String) {
        switch self {
        case .unknownAndNone:   return ("Unknown", "None")
        case .focusAndZoom:     return ("Focus", "Zoom")
        case .noneAndIris:      return ("None", "Iris")
        case .panAndTilt:       return ("Pan", "Tilt")
        }
    }
}

public struct PTZStatisticsValues: Equatable, JSONEncodable, CustomStringConvertible {
    let left: UInt32
    let right: UInt32
    
    public var description: String {
        "\(left)/\(right)"
    }
    public var toJSON: JSONValue {
        return [left, right]
    }
}

/// Obtain some usage statistics
/// Discovered by fuzzing
///
/// Those seem to reflect the number of time a motor switch direction
public struct PTZStatisticsState: PTZReadable {
    public static let name: String = "Statistics"
    public static let register: PTZRegister<PTZStatisticsGroup> = .init(0x01, 0x59)
    public let variant: PTZStatisticsGroup
    public var value: PTZStatisticsValues
    
    public init?(message: PTZMessage) {
        guard let stats = PTZStatisticsGroup.allCases.first(where: { message.isValidReply((0x41, UInt8($0.rawValue))) }) else { return nil }
        
        let left0 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 7, loRetainerIndex: 3, loRetainerMask: 0x08)).rawValue
        let left1 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 6, loRetainerIndex: 3, loRetainerMask: 0x04)).rawValue
        let left2 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 5, loRetainerIndex: 3, loRetainerMask: 0x02)).rawValue
        let left3 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 4, loRetainerIndex: 3, loRetainerMask: 0x01)).rawValue
        
        let right0 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 12, loRetainerIndex: 11, loRetainerMask: 0x01)).rawValue
        let right1 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex: 10, loRetainerIndex:  3, loRetainerMask: 0x40)).rawValue
        let right2 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex:  9, loRetainerIndex:  3, loRetainerMask: 0x20)).rawValue
        let right3 = message.parseArgument(type: PTZUInt.self, position: .custom(hiIndex: 13, loIndex:  8, loRetainerIndex:  3, loRetainerMask: 0x10)).rawValue

        self.variant = stats
        self.value = .init(
            left:  .init(b3: UInt8(left3),  b2: UInt8(left2),  b1: UInt8(left1),  b0: UInt8(left0)),
            right: .init(b3: UInt8(right3), b2: UInt8(right2), b1: UInt8(right1), b0: UInt8(right0))
        )
    }
    
    public var description: String {
        return "\(Self.name)(\(variant.names.0)=\(value.left), \(variant.names.1)=\(value.right))"
    }
}
