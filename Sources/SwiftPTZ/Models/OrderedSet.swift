//
//  OrderedSet.swift
//
//
//  Created by syan on 11/09/2024.
//

import Foundation

struct OrderedSet<T: Hashable> {
    private var dataArray: [T] = []
    private var dataSet: Set<T> = .init()
    
    mutating func append(_ item: T) {
        guard !dataSet.contains(item) else { return }
        dataSet.insert(item)
        dataArray.append(item)
    }
    
    var all: [T] {
        return dataArray
    }
}
