//
//  PTZUInt.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public struct PTZUInt {
    public let rawValue: UInt16
    
    public init(rawValue: UInt16) {
        self.rawValue = rawValue
    }
}

extension PTZUInt: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

extension PTZUInt: PTZValue {
    public init(ptzValue: UInt16) {
        self.rawValue = ptzValue
    }
    
    public var ptzValue: UInt16 {
        return rawValue
    }
    
    public static var allCases: [PTZUInt] { [.init(rawValue: 0)] }
    
    public var description: String {
        return String(rawValue)
    }
    
    public init?(from cliString: String) {
        guard let value = UInt16(cliString) else { return nil }
        self.rawValue = value
    }
    
    public var toJSON: JSONValue {
        return rawValue
    }
}
