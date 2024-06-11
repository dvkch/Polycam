//
//  Log.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation

struct Log {
    private static let lock = NSLock()
    static func w(tag: String, message: String) {
        lock.lock()
        defer { lock.unlock() }

        print("\(tag): \(message)")
    }
}
