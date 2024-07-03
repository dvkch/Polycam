//
//  Array+PTZ.swift
//
//
//  Created by syan on 03/07/2024.
//

import Foundation

extension RandomAccessCollection where Self.Index == Int {
    func last(n: Int) -> [Element] {
        let firstIndex = Swift.max(0, count - n)
        let lastIndex = Swift.max(0, count)
        return Array(self[firstIndex..<lastIndex])
    }
}

extension Collection where Element : BinaryInteger {
    var isZero: Bool {
        guard !isEmpty else { return true }
        return filter { $0 == 0 }.count == self.count
    }
}

extension Array {
    static func * (lhs: Self, rhs: Int) -> Self {
        var accumulator = Self()
        accumulator.reserveCapacity(Swift.max(1, lhs.count * rhs))
        for _ in 0..<rhs {
            accumulator.append(contentsOf: lhs)
        }
        return accumulator
    }
}

extension Array where Element == UInt8 {
    func split(startFilter: (Element) -> Bool) -> [Self] {
        let startIndicies = enumerated().filter { startFilter($0.element) }.map(\.offset)

        var subarrays = [Self]()

        for (messageIndex, startIndex) in startIndicies.enumerated() {
            let endIndex = (messageIndex == startIndicies.count - 1) ? self.count : startIndicies[messageIndex + 1]
            subarrays.append(Array(self[startIndex..<endIndex]))
        }

        return subarrays
    }
}
