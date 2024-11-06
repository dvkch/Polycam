//
//  PTZMacros.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

@main
struct PTZMacros: CompilerPlugin {
    var providingMacros: [Macro.Type] = [PTZDeviceState.self]
}
