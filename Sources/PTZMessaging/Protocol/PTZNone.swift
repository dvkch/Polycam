//
//  PTZNone.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

public struct PTZNone: Equatable, CLIDecodable, JSONEncodable, CustomStringConvertible {
    public init() {}
    
    public init?(from cliString: String) {
        guard cliString == "" else { return nil }
    }
    
    public var toJSON: JSONValue {
        return ""
    }
    
    public var description: String {
        "()"
    }
}
