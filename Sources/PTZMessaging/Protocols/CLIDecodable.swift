//
//  CLIDecodable.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation

public protocol CLIDecodable {
    init?(from cliString: String)
    static var cliStringExamples: [String] { get }
}

