//
//  Loggable.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation

enum LogLevel: Int, Comparable {
    case debug = 0
    case info
    case warning
    case error
    case fatal
    
    static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

protocol Loggable {
    var logLevel: LogLevel { get set }
    var logTag: String { get }
}

private let logLock = NSLock()
extension Loggable {
    func log(_ level: LogLevel, _ message: String) {
        guard level >= self.logLevel else { return }

        logLock.withLock {
            print("\(logTag): \(message)")
        }
    }
    
    mutating func withLogLevel(_ level: LogLevel, closure: (Self) throws -> ()) rethrows {
        let prevLevel = self.logLevel
        defer { self.logLevel = prevLevel }

        self.logLevel = level
        try closure(self)
    }
}