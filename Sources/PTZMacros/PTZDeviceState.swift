//
//  PTZDeviceState.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

#warning("USAGE:")
// public macro OptionSet<RawType>() = #externalMacro(module: "SwiftMacros", type: "OptionSetMacro")

import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

enum PTZMacroError: Error {
    case message(String)
}

/*
public struct PTZDeviceStateMacro: AttachedMacro {
    public static func expansion(
        of node: MacroExpansionDeclSyntax,
        in context: MacroExpansionContext
    ) throws -> DeclSyntax {
        
        func arg<T: SyntaxProtocol>(index: Int, as type: T.Type) -> T? {
            return node.arguments[node.arguments.index(node.arguments.startIndex, offsetBy: index)].expression.as(type)
        }
        
        // Extract macro parameters
        guard let nameExpr = arg(index: 0, as: StringLiteralExprSyntax.self)?.segments.first, case .stringSegment(let name) = nameExpr,
              let valueType = arg(index: 1, as: IdentifierTypeSyntax.self)?.name.text,
              let variantType = arg(index: 2, as: IdentifierTypeSyntax.self)?.name.text
        else {
            throw PTZMacroError.message("Invalid arguments for PTZDeviceState macro.")
        }
        
        // Extract the original struct members, like `description`
        let originalMembers = node.body?.members.members ?? []
        
        // Struct expansion
        let structDecl = """
        struct \(node.identifier.text): PTZState {
            static var name = "\(raw: name)"
            typealias Value = \(raw: valueType)
            typealias Variant = \(raw: variantType)
            
            var value: Value
            var variant: Variant
            
            init(_ value: Value, _ variant: Variant) {
                self.value = value
                self.variant = variant
            }
            
            \(raw: originalMembers)  // Keep original members like `description`
        }
        """
        
        // Camera extension
        let extensionDecl = """
        extension Camera {
            var \(name.content.text.camelCased): \(valueType) {
                get { self.send(\(node.identifier.text).self) }
            }
        }
        """
        
        return "\(structDecl)\n\n\(extensionDecl)"
    }
}

private extension String {
    var lowercasingFirst: String { prefix(1).lowercased() + dropFirst() }
    var uppercasingFirst: String { prefix(1).uppercased() + dropFirst() }

    var camelCased: String {
        guard !isEmpty else { return "" }
        let parts = components(separatedBy: .alphanumerics.inverted)
        let first = parts.first!.lowercasingFirst
        let rest = parts.dropFirst().map { $0.uppercasingFirst }

        return ([first] + rest).joined()
    }
}*/
