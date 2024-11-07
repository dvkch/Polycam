//
//  String+PTZ.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation

extension String {
    public func leftPad(count: Int, padding: Element) -> Self {
        var copy = self
        while copy.count < count {
            copy.insert(padding, at: startIndex)
        }
        return copy
    }
    
    internal var lowercasingFirst: String { prefix(1).lowercased() + dropFirst() }
    internal var uppercasingFirst: String { prefix(1).uppercased() + dropFirst() }
    
    public var camelCased: String {
        guard !isEmpty else { return "" }
        let parts = components(separatedBy: .alphanumerics.inverted)
        let first = parts.first!.lowercasingFirst
        let rest = parts.dropFirst().map { $0.uppercasingFirst }
        
        return ([first] + rest).joined()
    }
    
    public var quoted: String {
        return "\"\(self.replacingOccurrences(of: "\"", with: "\\\""))\""
    }
}


