//
//  PTZValue+Enum.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public protocol PTZEnumValue: PTZValue where Self: CaseIterable, Self: RawRepresentable, RawValue == UInt16 {
}

public extension PTZEnumValue {
    init(ptzValue: UInt16) {
        self = Self.allCases.first(where: { $0.ptzValue == ptzValue })!
    }
    
    var ptzValue: UInt16 {
        return UInt16(rawValue)
    }
    
    init?(from cliString: String) {
        if let item = Self.allCases.first(where: { $0.description.lowercased() == cliString.lowercased() }) {
            self = item
        }
        else if let value = UInt16(cliString) {
            self.init(rawValue: value)
        }
        else {
            return nil
        }
    }
    
    var toJSON: JSONValue {
        return rawValue
    }
}
