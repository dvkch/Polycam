//
//  PTZCameraMacros.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct TestPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        PTZState.self,
    ]
}
