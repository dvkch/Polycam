//
//  Array+PTZ.swift
//
//
//  Created by syan on 03/07/2024.
//

import Foundation

extension RandomAccessCollection where Self.Index == Int {
    public func element(at index: Int) -> Element? {
        if index < count {
            return self[index]
        }
        return nil
    }
}

extension RandomAccessCollection {
    public var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Array {
    public static func * (lhs: Self, rhs: Int) -> Self {
        var accumulator = Self()
        accumulator.reserveCapacity(Swift.max(1, lhs.count * rhs))
        for _ in 0..<rhs {
            accumulator.append(contentsOf: lhs)
        }
        return accumulator
    }
}

extension Array {
    public func split(startFilter: (Element) -> Bool) -> [Self] {
        let startIndicies = enumerated().filter { startFilter($0.element) }.map(\.offset)

        var subarrays = [Self]()

        for (messageIndex, startIndex) in startIndicies.enumerated() {
            let endIndex = (messageIndex == startIndicies.count - 1) ? self.count : startIndicies[messageIndex + 1]
            subarrays.append(Array(self[startIndex..<endIndex]))
        }

        return subarrays
    }
    
    public mutating func ensureLength(_ count: Int, filler: Element) {
        while self.count < count {
            self.append(filler)
        }
    }
    
    public mutating func takeFirst(_ n: Int) -> [Element] {
        let taken = Swift.min(n, count)
        let subarray = Array(self[0..<taken])
        removeFirst(taken)
        return subarray
    }
    
    public func pick(count: Int) -> [Element] {
        return (0..<count).compactMap { _ in self.randomElement() }
    }
}
