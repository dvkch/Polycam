//
//  Bytes+PTZ.swift
//  PTZ
//
//  Created by syan on 08/11/2024.
//

import Foundation
import PTZMessaging

internal extension Bytes {
    enum Comparison {
        case equal, closeEnough, different
    }
    
    func compare(_ other: Self, allowingVarianceOfOneAtIndex imperfectionIndex: Int) -> Comparison {
        guard self.count == other.count else { return .different }
        
        let mismatchIndices = (0..<count).filter { self[$0] != other[$0] }
        if mismatchIndices.isEmpty {
            return .equal
        }
        
        if mismatchIndices == [imperfectionIndex] && abs(Int(self[imperfectionIndex]) - Int(other[imperfectionIndex])) == 1 {
            return .closeEnough
        }
        
        return .different
    }
}
