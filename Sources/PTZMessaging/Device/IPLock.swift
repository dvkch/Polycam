//
//  IPLock.swift
//  PTZ
//
//  Created by syan on 18/08/2026.
//

import Foundation
#if canImport(Glibc)
import Glibc
#elseif canImport(Darwin)
import Darwin
#endif

internal final class IPLock {

    // MARK: Init
    internal init?(path: String) {
        let fd = open(path, O_CREAT | O_RDWR, 0o666)
        guard fd >= 0 else { return nil }
        self.fd = fd
    }

    deinit {
        close(fd)
    }

    // MARK: Properties
    private let fd: Int32

    // MARK: Locking
    /// Polls for the lock until acquired or `timeout` elapses. Returns whether it was acquired.
    internal func lock(timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while true {
            if flock(fd, LOCK_EX | LOCK_NB) == 0 {
                return true
            }
            if Date() >= deadline {
                return false
            }
            usleep(1000)
        }
    }

    internal func unlock() {
        flock(fd, LOCK_UN)
    }
}
