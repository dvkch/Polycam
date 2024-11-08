//
//  String+PTZ.swift
//  PTZ
//
//  Created by syan on 06/11/2024.
//

import Foundation

internal extension String {
    func leftPad(count: Int, padding: Element) -> Self {
        var copy = self
        while copy.count < count {
            copy.insert(padding, at: startIndex)
        }
        return copy
    }
}

internal extension String {
    var lowercasingFirst: String { prefix(1).lowercased() + dropFirst() }
    var uppercasingFirst: String { prefix(1).uppercased() + dropFirst() }
    
    var camelCased: String {
        guard !isEmpty else { return "" }
        let parts = components(separatedBy: .alphanumerics.inverted)
        let first = parts.first!.lowercasingFirst
        let rest = parts.dropFirst().map { $0.uppercasingFirst }
        
        return ([first] + rest).joined()
    }
}


