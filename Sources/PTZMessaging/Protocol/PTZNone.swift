//
//  PTZNone.swift
//  SwiftPTZ
//
//  Created by syan on 05/11/2024.
//

public struct PTZNone: Equatable, CLIDecodable, Encodable {
    public init() {}
    
    public init?(from cliString: String) {
        guard cliString == "" else { return nil }
    }
    
    public func encode(to encoder: any Encoder) throws {
    }
}
