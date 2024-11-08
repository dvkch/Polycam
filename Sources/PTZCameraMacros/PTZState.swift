//
//  PTZState.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

internal enum PTZCameraMacrosError: Error {
    case message(String)
}

internal extension FreestandingMacroExpansionSyntax {
    func argument<T: ExprSyntaxProtocol>(at index: Int, as type: T.Type) -> T? {
        return arguments[arguments.index(arguments.startIndex, offsetBy: index)].expression.as(type)
    }
    
    func typeArgument(at index: Int) throws -> DeclReferenceExprSyntax {
        guard let typeExpr = argument(at: index, as: MemberAccessExprSyntax.self),
              let typeName = typeExpr.base?.as(DeclReferenceExprSyntax.self)?.trimmed,
                typeExpr.declName.trimmed.description == "self"
        else {
            throw PTZCameraMacrosError.message("Argument at index \(index) should be a type expression")
        }
        return typeName.trimmed
    }
}

internal struct PTZState: DeclarationMacro {
    static func expansion(of node: some FreestandingMacroExpansionSyntax, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        let kinds = ["RWD", "RW", "R", "W"]
        guard let kind = node.argument(at: 0, as: StringLiteralExprSyntax.self)?.segments.first?.description else {
            throw PTZCameraMacrosError.message("Argument at index 0 should be the state kind (\(kinds.joined(separator: ", ")))")
        }
        guard kinds.contains(kind) else {
            throw PTZCameraMacrosError.message("Unknown state kind '\(kind)', should be one of \(kinds.joined(separator: ", "))")
        }
        
        let stateType   = try node.typeArgument(at: 1)
        let variantType = try node.typeArgument(at: 2)
        let valueType   = try node.typeArgument(at: 3)

        let stateName = stateType.description.removingPrefix("PTZ").removingSuffix("State")
        let getterName = stateName.lowercasingFirst
        var setterName = "set" + stateName
        
        if stateName.hasSuffix("Action") {
            setterName = "start" + stateName.removingSuffix("Action")
        }

        var getter: DeclSyntax = ""
        var setter: DeclSyntax = ""
        let debounceDef = kind == "RWD" ? ", debounce: Bool = true" : ""
        let debounceArg = kind == "RWD" ? ", debounce: debounce" : ""

        if variantType.description != "PTZNone" && valueType.description != "PTZNone" {
            if kind.contains("R") {
                getter =
                """
                func \(raw: getterName)(for variant: \(variantType)) throws(CameraError) -> \(valueType) {
                    try get(\(stateType).self, for: variant)
                }
                """
            }
            if kind.contains("W") {
                setter =
                """
                func \(raw: setterName)(_ value: \(valueType), for variant: \(variantType)\(raw: debounceDef)) throws(CameraError) {
                    try set(\(stateType)(value, for: variant)\(raw: debounceArg))
                }
                """
            }
        }
        else if valueType.description != "PTZNone" {
            if kind.contains("R") {
                getter =
                """
                func \(raw: getterName)() throws(CameraError) -> \(valueType) {
                    try get(\(stateType).self)
                }
                """
            }
            if kind.contains("W") {
                setter =
                """
                func \(raw: setterName)(_ value: \(valueType)\(raw: debounceDef)) throws(CameraError) {
                    try set(\(stateType)(value)\(raw: debounceArg))
                }
                """
            }
        }
        else {
            if kind.contains("R") {
                getter =
                """
                func \(raw: getterName)() throws(CameraError) -> \(valueType) {
                    try get(\(stateType).self)
                }
                """
            }
            if kind.contains("W") {
                setter =
                """
                func \(raw: setterName)() throws(CameraError) {
                    try set(\(stateType)(.init()))
                }
                """
            }
        }
        
        return [getter, setter]
    }
}
