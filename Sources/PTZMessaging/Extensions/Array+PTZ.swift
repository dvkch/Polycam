//
//  Array+PTZ.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation

internal extension RandomAccessCollection where Self.Index == Int {
    func element(at index: Int) -> Element? {
        if index < count {
            return self[index]
        }
        return nil
    }
}

internal extension RandomAccessCollection {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

internal extension Array {
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
}
