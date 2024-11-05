//
//  Loggable.swift
//
//
//  Created by syan on 09/01/2024.
//

import Foundation

public protocol Loggable {
    var logLevel: LogLevel { get set }
    var logTag: String { get }
}

public enum LogLevel: Int, Comparable {
    case debug = 0
    case info
    case warning
    case error
    case fatal
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

private let logLock = NSLock()
extension Loggable {
    public func log(_ level: LogLevel, _ message: String) {
        guard level >= self.logLevel else { return }

        logLock.withLock {
            print("\(logTag): \(message)")
        }
    }
    
    public mutating func withLogLevel(_ level: LogLevel, closure: (Self) throws -> ()) rethrows {
        let prevLevel = self.logLevel
        defer { self.logLevel = prevLevel }

        self.logLevel = level
        try closure(self)
    }
}
