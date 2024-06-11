//
//  NSLock+PTZ.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation

extension NSLock {
    func locking<T>(_ block: () throws -> T) rethrows -> T {
        self.lock()
        defer { self.unlock() }
        return try block()
    }
}
