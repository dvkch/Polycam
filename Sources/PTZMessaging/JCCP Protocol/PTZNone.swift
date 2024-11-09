//
//  PTZNone.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

public struct PTZNone: Equatable, CLIDecodable, JSONEncodable {
    public init() {}
    
    public var toJSON: JSONValue {
        return ""
    }
}

extension PTZNone: PTZVariant {
    public var registerOffset: UInt8 { 0 }
    
    public init?(from cliString: String) {
        guard cliString == "" else { return nil }
    }
    
    public static var cliStringExamples: [String] { [] }
    
    public static var allCases: [PTZNone] { [.init()] }

    public var description: String { "" }
}

extension PTZNone: RawRepresentable {
    public var rawValue: UInt8 {
        return 0
    }
    
    public init?(rawValue: UInt8) {
        guard rawValue == 0 else { return nil }
    }
}
