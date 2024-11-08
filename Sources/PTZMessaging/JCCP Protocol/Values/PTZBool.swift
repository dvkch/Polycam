//
//  PTZBool.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public struct PTZBool {
    public let rawValue: Bool
    
    public init(rawValue: Bool) {
        self.rawValue = rawValue
    }
}

extension PTZBool: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: BooleanLiteralType) {
        self.init(rawValue: value)
    }
}

public extension PTZBool {
    static var on: PTZBool { .init(rawValue: true) }
    static var off: PTZBool { .init(rawValue: false) }
}

extension PTZBool: PTZValue {
    public init(ptzValue: UInt16) {
        self.rawValue = ptzValue > 0
    }
    
    public var ptzValue: UInt16 {
        return rawValue ? 0x01 : 0x00
    }
    
    public static var allCases: [PTZBool] { [.off, .on] }
    
    public var description: String {
        return rawValue ? "on" : "off"
    }
    
    public init?(from cliString: String) {
        if cliString == "true" || cliString == "1" {
            self.rawValue = true
        }
        else if cliString == "false" || cliString == "0" {
            self.rawValue = false
        }
        else {
            return nil
        }
    }
    
    public var toJSON: JSONValue {
        return rawValue
    }
}
