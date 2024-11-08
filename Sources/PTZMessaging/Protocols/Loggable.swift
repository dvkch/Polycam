//
//  Loggable.swift
//  PTZ
//
//  Created by syan on 09/01/2024.
//

import Foundation

public protocol Loggable {
    var logLevel: LogLevel { get set }
    var logTag: String { get }
}

public enum LogLevel: String, Comparable, Sendable {
    case debug   = "debug"
    case info    = "info"
    case warning = "warning"
    case error   = "error"
    case fatal   = "fatal"
    
    public var level: Int {
        switch self {
        case .debug:   0
        case .info:    1
        case .warning: 2
        case .error:   3
        case .fatal:   4
        }
    }
    
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.level < rhs.level
    }
}

private let logLock = NSLock()
extension Loggable {
    public func log(_ level: LogLevel, _ message: String) {
        guard level >= self.logLevel else { return }

        logLock.withLock {
            let content = "\(logTag): \(message)"
            try! FileHandle.standardError.write(contentsOf: Data((content + "\n").utf8))
        }
    }
    
    public mutating func withLogLevel(_ level: LogLevel, closure: (Self) throws -> ()) rethrows {
        let prevLevel = self.logLevel
        defer { self.logLevel = prevLevel }

        self.logLevel = level
        try closure(self)
    }
}
