//
//  String+PTZ.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

internal extension String {
    var lowercasingFirst: String { prefix(1).lowercased() + dropFirst() }
    
    func removingPrefix(_ prefix: String) -> String {
        return hasPrefix(prefix) ? String(dropFirst(prefix.count)) : self
    }
    
    func removingSuffix(_ suffix: String) -> String {
        return hasSuffix(suffix) ? String(dropLast(suffix.count)) : self
    }
}
