//
//  Array+PTZ.swift
//  PTZ
//
//  Created by syan on 07/11/2024.
//

import Foundation

internal extension Array {
    mutating func takeFirst(_ n: Int) -> [Element] {
        let taken = Swift.min(n, count)
        let subarray = Array(self[0..<taken])
        removeFirst(taken)
        return subarray
    }
}
