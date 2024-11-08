//
//  PTZVariant.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

public protocol PTZVariant: Equatable, CaseIterable, CustomStringConvertible, CLIDecodable, RawRepresentable where RawValue: CustomStringConvertible {
    var registerOffset: UInt8 { get }
}

public extension PTZVariant {
    init?(from cliString: String) {
        if let item = Self.allCases.first(where: { $0.description.lowercased() == cliString.lowercased() }) {
            self = item
        }
        else if let item = Self.allCases.first(where: { $0.rawValue.description.lowercased() == cliString.lowercased() }) {
            self = item
        }
        else {
            return nil
        }
    }
}

public extension PTZVariant where Self: RawRepresentable, RawValue == UInt8 {
    var registerOffset: UInt8 { rawValue }
}
