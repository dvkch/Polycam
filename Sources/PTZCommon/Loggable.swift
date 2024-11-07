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

public enum LogLevel: String, Comparable {
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

        var stdErr = LoggableStdErr()
        logLock.withLock {
            print("\(logTag): \(message)", to: &stdErr)
        }
    }
    
    public mutating func withLogLevel(_ level: LogLevel, closure: (Self) throws -> ()) rethrows {
        let prevLevel = self.logLevel
        defer { self.logLevel = prevLevel }

        self.logLevel = level
        try closure(self)
    }
}

private struct LoggableStdErr: TextOutputStream {
    func write(_ string: String) {
        try! FileHandle.standardError.write(contentsOf: Data(string.utf8))
    }
}
