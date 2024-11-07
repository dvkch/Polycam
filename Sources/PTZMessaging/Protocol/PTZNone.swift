//
//  PTZNone.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

public struct PTZNone: Equatable, CLIDecodable, JSONEncodable, CaseIterable, CustomStringConvertible {
    public init() {}
    
    public init?(from cliString: String) {
        guard cliString == "" else { return nil }
    }
    
    public var toJSON: JSONValue {
        return ""
    }
    
    public static var allCases: [PTZNone] {
        return [.init()]
    }

    public var description: String {
        ""
    }
}
