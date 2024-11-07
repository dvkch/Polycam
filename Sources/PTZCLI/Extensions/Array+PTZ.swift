//
//  Array+PTZ.swift
//  PTZ
//
//  Created by syan on 05/11/2024.
//

import Foundation
import PTZMessaging

extension Bytes {
    func hexString(condensedWith other: Bytes, stoppedEarly: Bool) -> String {
        guard self != other else { return self.hexString }

        var commonLastIndex = 0
        for i in 0..<(Swift.min(count, other.count)) {
            if self[0...i] == other[0...i] {
                commonLastIndex = i
            }
        }
        let part1 = Array( self[(commonLastIndex + 1)..<self.count ]).hexString
        let part2 = Array(other[(commonLastIndex + 1)..<other.count]).hexString
        let suffix2 = stoppedEarly ? "+" : ""
        return Array(self[0...commonLastIndex]).hexString + " (" + part1 + " -> " + part2 + suffix2 + ")"
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
