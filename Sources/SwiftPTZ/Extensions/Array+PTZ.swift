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

extension String {
    func leftPad(count: Int, padding: Element) -> Self {
        var copy = self
        while copy.count < count {
            copy.insert(padding, at: startIndex)
        }
        return copy
    }
}

extension Array {
    func split(startFilter: (Element) -> Bool) -> [Self] {
        let startIndicies = enumerated().filter { startFilter($0.element) }.map(\.offset)

        var subarrays = [Self]()

        for (messageIndex, startIndex) in startIndicies.enumerated() {
            let endIndex = (messageIndex == startIndicies.count - 1) ? self.count : startIndicies[messageIndex + 1]
            subarrays.append(Array(self[startIndex..<endIndex]))
        }

        return subarrays
    }
    
    mutating func ensureLength(_ count: Int, filler: Element) {
        while self.count < count {
            self.append(filler)
        }
    }
    
    mutating func takeFirst(_ n: Int) -> [Element] {
        let taken = Swift.min(n, count)
        let subarray = Array(self[0..<taken])
        removeFirst(taken)
        return subarray
    }
    
    func pick(count: Int) -> [Element] {
        return (0..<count).compactMap { _ in self.randomElement() }
    }
}

extension Array where Element: Collection {
    var flatten: [Element.Element] {
        return reduce([], +)
    }
}

extension Array where Element: Equatable {
    func elementAfter(_ element: Element, or defElement: Element) -> Element {
        guard let index = self.firstIndex(of: element) else { return defElement }
        guard index + 1 < count else { return defElement }
        return self[index + 1]
    }

    func elementBefore(_ element: Element, or defElement: Element) -> Element {
        guard let index = self.firstIndex(of: element) else { return defElement }
        guard index - 1 >= 0 else { return defElement }
        return self[index - 1]
    }
}

extension Array where Element == UInt16 {
    func closest(to element: Element) -> Element? {
        guard !isEmpty else { return nil }
        let distances = self.map { abs(Int32($0) - Int32(element)) }
        let smallestDistance = distances.min()!
        let indexOfClosest = distances.firstIndex(of: smallestDistance)!
        return self[indexOfClosest]
    }
}

extension Bytes {
    func stringRepresentation(condensedWith other: Bytes, stoppedEarly: Bool) -> String {
        guard self != other else { return self.stringRepresentation }

        var commonLastIndex = 0
        for i in 0..<(Swift.min(count, other.count)) {
            if self[0...i] == other[0...i] {
                commonLastIndex = i
            }
        }
        let part1 = Array( self[(commonLastIndex + 1)..<self.count ]).stringRepresentation
        let part2 = Array(other[(commonLastIndex + 1)..<other.count]).stringRepresentation
        let suffix2 = stoppedEarly ? "+" : ""
        return Array(self[0...commonLastIndex]).stringRepresentation + " (" + part1 + " -> " + part2 + suffix2 + ")"
    }

}
