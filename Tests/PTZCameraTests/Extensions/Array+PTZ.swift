//
//  Array+PTZ.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation

extension Array where Element: Comparable {
    func pick(_ count: Int) -> [Element] {
        guard !isEmpty else { return [] }
        return (0..<count).map { _ in self.randomElement()! }.sorted()
    }
}

extension Array where Element: RawRepresentable, Element.RawValue: Comparable {
    func pick(_ count: Int) -> [Element] {
        guard !isEmpty else { return [] }
        return (0..<count).map { _ in self.randomElement()! }.sorted(by: { $0.rawValue < $1.rawValue })
    }
}
