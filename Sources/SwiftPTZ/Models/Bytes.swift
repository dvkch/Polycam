//
//  Bytes.swift
//
//
//  Created by syan on 05/07/2024.
//

import Foundation

typealias Bytes = [UInt8]

extension Bytes {
    var stringRepresentation: String {
        self.map(\.stringRepresentation).joined(separator: " ")
    }
    
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

extension String {
    var bytes: Bytes {
        self
            .components(separatedBy: " ")
            .map { Byte($0, radix: 16)! }
    }
}
